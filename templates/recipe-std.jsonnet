local base_images = "ghcr.io/ublue-os/";
local secure_images = "ghcr.io/secureblue/";
local project_image_name = "atomic-studio";

local modules = {
    no_hardened: ["gui-apps","packages", "files", "scripts", "bling", "services"],
    hardened: ["gui-apps","packages", "files", "scripts-noptyxis", "hardened-ptyxis-flatpak","bling", "services"],
    nvidia: ["scripts"],
    amd: ["packages", "scripts"],
    gnome: ["apps", "files", "scripts"],
    plasma: ["apps", "files", "scripts"],
    audio: ["audinux", "pipewire-packages"] 
};

local gen_image_tags(baseimage, nvidia=false, hardened=false) = (if baseimage == "silverblue" then "-gnome" else "") + (if nvidia then "-nvidia" else "") + (if hardened then "-hardened" else "");
local gen_module_definition(prefix, modules) = [ { "from-file": (prefix + "/" + module + ".yml")}  for module in modules ];

local image(baseimage, imageversion, nvidia=false, hardened=false) = {
    name: project_image_name + gen_image_tags(baseimage, nvidia, hardened),
    description: "Operating system based on Fedora Atomic meant for content creators and artists",
    "base-image": (if hardened then secure_images else base_images) + baseimage + (if nvidia then "-nvidia" else "-main") + (if hardened then "-userns-hardened" else ""),
    "image-version": imageversion,
    modules:  
    (
        if hardened then 
            gen_module_definition("common/shared", modules.hardened)
        else 
            gen_module_definition("common/shared", modules.no_hardened)
    ) +
    (
        gen_module_definition("common/audio", modules.audio)
    ) +
    ( 
        if nvidia then 
            gen_module_definition("common/shared/nvidia", modules.nvidia)
        else 
            gen_module_definition("common/shared/amd", modules.amd)  
    ) + (
        if baseimage == "silverblue" then 
            gen_module_definition("common/gnome", modules.gnome) 
        else 
            gen_module_definition("common/plasma", modules.plasma)
    ),
};

{
    "recipe.yml": image("kinoite", "latest", false, false),
    "recipe-nvidia.yml": image("kinoite", "latest", true, false),
    "recipe-hardened.yml": image("kinoite", "latest", false, true),
    "recipe-nvidia-hardened.yml": image("kinoite", "latest", true, true),

    "recipe-gnome.yml": image("silverblue", "latest", false, false),
    "recipe-gnome-nvidia.yml": image("silverblue", "latest", true, false),
    "recipe-gnome-hardened.yml": image("silverblue", "latest", false, true),
    "recipe-gnome-nvidia-hardened.yml": image("silverblue", "latest", true, true),
}
