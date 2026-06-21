swayimg.text.set_size(10)
swayimg.text.set_padding(4)
swayimg.text.set_spacing(0)
swayimg.text.set_foreground(0xffffffff)
swayimg.text.set_background(0x00000000)
swayimg.text.set_shadow(0xff000000)

swayimg.viewer.set_text("bottomleft", {
    "{name}",
})

swayimg.viewer.on_key("q", function()
    swayimg.exit()
end)

swayimg.viewer.on_key("w", function()
    local image = swayimg.viewer.get_image()
    os.execute("mangostyle '" .. image.path .. "'")
end)
