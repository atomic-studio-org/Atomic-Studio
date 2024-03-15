<div align="center">
    <img src="./assets/studio-blob.png" alt="drawing" width="200rem"/> 
    <h1 style="font-size: 48px; margin-left: 0.1em; text-align: center;">Atomic Studio</h1>
    <a href="https://github.com/atomic-studio-org/Atomic-Studio/actions/workflows/build.yml"><img src="https://github.com/atomic-studio-org/Atomic-Studio/actions/workflows/build.yml/badge.svg" alt="Build Status" /></a>
    <a href="https://github.com/atomic-studio-org/Atomic-Studio/actions/workflows/build-iso.yml)"><img src="https://github.com/atomic-studio-org/Atomic-Studio/actions/workflows/build-iso.yml/badge.svg" alt="Build ISO Status"/></a>
    <a href="https://github.com/atomic-studio-org/Atomic-Studio/main/LICENSE.md"><img src="https://img.shields.io/github/license/atomic-studio-org/Atomic-Studio?style=plastic&style=social" alt="Image License: APACHE 2.0"/></a>
    <a href="https://artifacthub.io/packages/search?repo=atomic-studio"><img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/atomic-studio" alt="Atomic Studio on ArtifactHub" /></a>
</div>

<br/>
Want a reproducible and atomic environment for all your content creation needs? Then Atomic Studio is for you! We provide many Graphics, Audio and Video production software and tweaks to make your content creation as pratical as possible, the idea is to install this system with your favorite flavour and start creating right away!
<br/><br/>

This image is distributed in two flavours: Plasma and Gnome, they have the same applications, but some minor differentes in theming, and some adapted aplications for better system integration (like `qpwgraph` <-> `helvum`). You can install this image by either installing the (current netinstall) ISO in [Releases](https://github.com/atomic-studio-org/Atomic-Studio/releases) or by rebasing your system to one of them.

You can also use hardened images that have less hardware compatibility but have much better security!

### Rebasing

```shell
# Latest Plasma version
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/atomic-studio-org/atomic-studio:latest

# Latest Plasma version + Nvidia
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/atomic-studio-org/atomic-studio-nvidia:latest

# Latest Gnome version
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/atomic-studio-org/atomic-studio-gnome:latest

# Latest Gnome version + Nvidia
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/atomic-studio-org/atomic-studio-gnome-nvidia:latest

# Add -hardened to get the hardened image versions. E.g.:
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/atomic-studio-org/atomic-studio-hardened:latest
```

> Note: If these commands do not work first time, you are probably on a vanilla Fedora Atomic system, please run these but, instead of `ostree-image-signed:docker://`, use `ostree-unverified-registry:`, like the follwing command:
>```shell
># Unsigned version, please refrain from using this! - Only rebase to this first, then rebase to a signed image if you arent on a Universal Blue system
>rpm-ostree rebase ostree-unverified-registry:ghcr.io/atomic-studio-org/atomic-studio:latest
>```

## Contributing

Thank you very much for using Atomic Studio! Feel free to send pull requests and issues about anything that you feel should be improved in this project. We have a `studio reporter` utility that will help you out to get valuable information to write your Issues and ideas. 

When writing a pull request, make sure you have Nushell and Nix installed on your system, because we are quite big fans of these tecnologies, and, before commiting, make sure to run `nix flake check` to check if your code passes our tests!


## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/legacy-template
```

## Final Note

> This operating system image is not affilitated with Ubuntu or Fedora at all! We just use the Fedora base and get some inspirations from the Ubuntu Studio project. If you like this project, make sure to check out Ubuntu Studio proper!
