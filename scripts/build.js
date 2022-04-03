const create_icon_numbers = require("./create_icon_numbers")
const package_mod = require("./package_mod")


async function main() {
    await create_icon_numbers()
    await package_mod()
}
main()
