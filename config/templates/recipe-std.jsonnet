local project = {
    image_name: "atomic-studio",
    description: "Operating system based on Fedora Atomic meant for content creators and artists",
    base_images: "ghcr.io/ublue-os",
};

local modules = {
    shared: ["gui-apps","packages", "files", "scripts", "bling", "services"],
    nvidia: ["scripts"],
    amd: ["packages", "scripts"],
    gnome: ["apps", "scripts"],
    plasma: ["apps", "scripts"],
    audio: ["audinux", "pipewire-packages"],
    misc: [{ "type": "yafti" }, { "type": "signing" }],
};

local gen_module_definition(prefix, modules) = [
    { "from-file": ("common/" + prefix + "/" + module + ".yml")}  
    for module in modules 
];

local gen_image_tags(baseimage, nvidia) = (if (baseimage == "silverblue") then "-gnome" else "") + (if(nvidia) then "-nvidia" else ""); 

local image(baseimage, nvidia) = {
    "name": project.image_name + gen_image_tags(baseimage, nvidia),
    "description": project.description,
    "base-image": project.base_images + "/" + baseimage + (if (nvidia) then "-nvidia" else "-main"),
    "image-version": "latest",
    "modules": std.flattenArrays(
    [
        gen_module_definition("shared", modules.shared),
        if (nvidia) then gen_module_definition("shared/nvidia", modules.nvidia) else gen_module_definition("shared/amd", modules.amd),
        if (baseimage == "silverblue") then gen_module_definition("gnome", modules.gnome) else gen_module_definition("plasma", modules.plasma),
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
