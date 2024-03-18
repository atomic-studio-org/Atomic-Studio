local images = {
    base: "ghcr.io/ublue-os",
    hardened: "ghcr.io/secureblue",
};

local project = {
    image_name: "atomic-studio",
    description: "Operating system based on Fedora Atomic meant for content creators and artists",
};

local modules = {
    no_hardened: ["gui-apps","packages", "files", "scripts", "bling", "services"],
    hardened: ["gui-apps","packages", "files", "scripts-noptyxis", "hardened-ptyxis-flatpak","bling", "services"],
    nvidia: ["scripts"],
    amd: ["packages", "scripts"],
    gnome: ["apps", "files", "scripts"],
    plasma: ["apps", "files", "scripts"],
    audio: ["audinux", "pipewire-packages", "wine-tkg", "wine-tkg-scripts"],
    misc: [{ "type": "yafti" }, { "type": "signing" }],
};

local cond(boolcond, iftrue, iffalse) = if (boolcond) then iftrue else iffalse;

local gen_image_tags(base_image, nvidia, hardened) = std.join("", [
    cond(base_image == "silverblue", "-gnome", ""),
    cond(nvidia, "-nvidia", ""),
    cond(hardened, "-hardened", ""),
]);

local gen_baseimage_url(base_image, nvidia, hardened) = std.join("", [
    cond(hardened, images.hardened + "/", images.base + "/"),
    base_image,
    cond(nvidia, "-nvidia", "-main"),
    cond(hardened, "-userns-hardened", ""),
]);

local gen_module_definition(prefix, modules) = [
    { "from-file": ("common/" + prefix + "/" + module + ".yml")}  
    for module in modules 
];

local image(baseimage, nvidia, hardened) = {
    "name": project.image_name + gen_image_tags(baseimage, nvidia, hardened),
    "description": project.description,
    "base-image": gen_baseimage_url(baseimage, nvidia, hardened),
    "image-version": "latest",
    "modules": std.flattenArrays(
    [
        cond(hardened, 
            gen_module_definition("shared", modules.hardened), 
            gen_module_definition("shared", modules.no_hardened)
        ),
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
  [prefix + gen_image_tags(base_image, nvidia, hardened) + ".yml"]: image(base_image, nvidia, hardened)
  for nvidia in [
    true, false
  ] for hardened in [ 
    true, false
  ] for base_image in [
    "kinoite", "silverblue"
  ] 
};

gen_all_variations("recipe")
