local project = {
    image_name: "atomic-studio",
    description: "Operating system based on Fedora Atomic meant for content creators and artists",
    base_images: "ghcr.io/ublue-os",
};

local modules = {
    shared: ["packages", "files", "scripts", "bling", "services"],
    fx: ["apps", "flatpaks", "audinux"],
    nvidia: [],
    amd: ["packages", "scripts"],
    gnome: ["apps"],
    plasma: ["apps", "scripts", "files"],
    misc: [{ "type": "yafti" }, { "type": "signing" }],
};

local gen_module_definition(prefix, modules) = [
    { "from-file": ("common/" + prefix + "/" + module + ".yml")}  
    for module in modules 
];

local gen_image_tags(baseimage, nvidia, fx) = 
    (if (baseimage == "silverblue") then "-gnome" else "") 
    + (if(fx) then "-fx" else "")
    + (if(nvidia) then "-nvidia" else "");

local image(baseimage, nvidia, fx) = {
    "name": project.image_name + gen_image_tags(baseimage, nvidia, fx),
    "description": project.description,
    "base-image": project.base_images + "/" + baseimage + (if (nvidia) then "-nvidia" else "-main"),
    "image-version": "latest",
    "modules": std.flattenArrays(
    [
        gen_module_definition("shared", modules.shared),
        if (nvidia) then [] else gen_module_definition("shared/amd", modules.amd),
        if (baseimage == "silverblue") then gen_module_definition("gnome", modules.gnome) else gen_module_definition("plasma", modules.plasma),
        if (fx) then gen_module_definition("fx", modules.fx) else [],
        modules.misc,
    ]),
};

local gen_all_variations(prefix) = {
  [prefix + gen_image_tags(base_image, nvidia, fx) + ".yml"]: image(base_image, nvidia, fx)
  for nvidia in [
    true, false
  ] for base_image in [
    "kinoite", "silverblue"
  ] for fx in [
    true, false
  ]
};

gen_all_variations("recipe")
