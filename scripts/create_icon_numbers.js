const Jimp = require("jimp");

(async () => {
    const font = await Jimp.loadFont(Jimp.FONT_SANS_32_WHITE)

    for (let x = 0; x < 3; x++) {
        for (let i = 0; i < 10; i++) {
            // Create transparent image
            const image = new Jimp(64, 64, 0x00000000);

            // Draw the number Gomme10x20n.fnt
            image.print(font, x * 20, 15, i.toString());
            image.color([{
                apply: "lighten",
                params: [100],
            }])
            image.contrast(1)

            // Save the image
            await image.writeAsync(`./graphics/icons/generated/number_${i}_${x}.png`);
        }
    }
})()
