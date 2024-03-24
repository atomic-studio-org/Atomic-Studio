local images = {
    base: "ghcr.io/ublue-os",
};

local project = {
    image_name: "atomic-studio",
    description: "Operating system based on Fedora Atomic meant for content creators and artists",
};

local modules = {
    shared: ["gui-apps","packages", "files", "scripts", "bling", "services"],
    nvidia: ["scripts"],
    amd: ["packages", "scripts"],
    gnome: ["apps", "files", "scripts"],
    plasma: ["apps", "files", "scripts"],
    audio: ["audinux", "pipewire-packages"],
    misc: [{ "type": "yafti" }, { "type": "signing" }],
};

local cond(boolcond, iftrue, iffalse) = if (boolcond) then iftrue else iffalse;

local gen_image_tags(base_image, nvidia) = std.join("", [
    cond(base_image == "silverblue", "-gnome", ""),
    cond(nvidia, "-nvidia", ""),
]);

local gen_baseimage_url(base_image, nvidia) = std.join("", [
    base_image,
    cond(nvidia, "-nvidia", "-main"),
]);

local gen_module_definition(prefix, modules) = [
    { "from-file": ("common/" + prefix + "/" + module + ".yml")}  
    for module in modules 
];

local image(baseimage, nvidia) = {
    "name": project.image_name + gen_image_tags(baseimage, nvidia),
    "description": project.description,
    "base-image": gen_baseimage_url(baseimage, nvidia),
    "image-version": "latest",
    "modules": std.flattenArrays(
    [
        gen_module_definition("shared", modules.shared),
        cond(nvidia, 
            gen_module_definition("shared/nvidia", modules.nvidia),
            gen_module_definition("shared/amd", modules.amd)  
        ),
        cond(baseimage == "silverblue",
            gen_module_definition("gnome", modules.gnome), 
            gen_module_definition("plasma", modules.plasma)
        ),
        gen_module_definition("audio", modules.audio),
        modules.misc,
    ]),
};

local gen_all_variations(prefix) = {
  [prefix + gen_image_tags(base_image, nvidia) + ".yml"]: image(base_image, nvidia)
  for nvidia in [
    true, false
  ] for base_image in [
    "kinoite", "silverblue"
  ] 
};

gen_all_variations("recipe")
