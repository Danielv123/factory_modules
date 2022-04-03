"use strict"
const events = require("events")
const fs = require("fs-extra")
const JSZip = require("jszip")
const klaw = require("klaw")
const path = require("path")
const yargs = require("yargs")
const child_process = require("child_process")
const util = require("util")
const minimatch = require("minimatch")

async function main() {
	const args = yargs
		.scriptName("build")
		.options({
			'build': { describe: "Build mod(s)", type: 'boolean', default: true },
			'pack': { describe: "Pack into zip file", type: 'boolean', default: true },
			'source-dir': { describe: "Path to mod source directory", nargs: 1, type: 'string', default: "" },
			'output-dir': { describe: "Path to output built mod(s)", nargs: 1, type: 'string', default: "dist" },
		})
		.argv

	let info = JSON.parse(await fs.readFile(path.join(args.sourceDir, "info.json")))
	
	await buildMod(args, info)
}

async function checkPath(path) {
    // Read filters from .buildignore
    let filters = []
    if (await fs.pathExists(".buildignore")) {
        let file = await fs.readFile(".buildignore", "utf8")
        for (let line of file.split("\n")) {
            filters.push(line.replace("\r", ""))
        }
    }
    // Check for files that match the filters
    for (let filter of filters) {
        if (minimatch(path, filter, {
            dot: true,
        })) {
            // console.log(`Skipping ${path}`)
            return false
        }
    }
    console.log(`Packing ${path}`)
    return true
}

async function buildMod(args, info) {
	if (args.build) {
		await fs.ensureDir(args.outputDir)
		let modName = `${info.name}_${info.version}`

		if (args.pack) {
			let zip = new JSZip()
			let walker = klaw(args.sourceDir)
				.on('data', async item => {
					if (item.stats.isFile()) {
						// On Windows the path created uses backslashes as the directory sepparator
						// but the zip file needs to use forward slashes.  We can't use the posix
						// version of relative here as it doesn't work with Windows style paths.
                        let basePath = path.relative(args.sourceDir, item.path).replace(/\\/g, "/")
                        
                        if (await checkPath(basePath)) {
                            zip.file(path.posix.join(modName, basePath), fs.createReadStream(item.path))
                        }
					}
				})
			await events.once(walker, 'end')

			for (let [fileName, pathParts] of Object.entries(info.additional_files || {})) {
				let filePath = path.join(args.sourceDir, ...pathParts)
				if (!await fs.pathExists(filePath)) {
					throw new Error(`Additional file ${filePath} does not exist`)
				}
				zip.file(path.posix.join(modName, fileName), fs.createReadStream(filePath))
			}
			delete info.additional_files

			zip.file(path.posix.join(modName, "info.json"), JSON.stringify(info, null, 4))

			let modPath = path.join(args.outputDir, `${modName}.zip`)
			console.log(`Writing ${modPath}`)
			let writeStream = zip.generateNodeStream().pipe(fs.createWriteStream(modPath))
			await events.once(writeStream, 'finish')

		} else {
			let modDir = path.join(args.outputDir, modName)
			if (await fs.exists(modDir)) {
				console.log(`Removing existing build ${modDir}`)
				await fs.remove(modDir)
			}
			console.log(`Building ${modDir}`)
			await fs.copy(args.sourceDir, modDir)
			for (let [fileName, pathParts] of Object.entries(info.additional_files) || []) {
				let filePath = path.join(...pathParts)
				await fs.copy(filePath, path.join(modDir, fileName))
			}
			delete info.additional_files

			await fs.writeFile(path.join(modDir, "info.json"), JSON.stringify(info, null, 4))
		}
	}
}

module.exports = async function () {
    try {
        await main()
    } catch (e) {
        console.error(e)
        process.exit(1)
    }
}
