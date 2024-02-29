# Universal Studio

<div style="display: flex; align-items: center;">
    <div>
        Want Ubuntu Studio but in a reproducible and atomic environment? Then Universal Studio is for you! 
        We provide all the same packages that you would get with Ubuntu Studio, but in a stable, atomic and reliable for all your content creation needs.
    </div>
    <div>
        <img src="https://github.com/tulilirockz/Universal-Studio/assets/120808662/805140a1-eda7-418f-87c8-f8ea319502a7" alt="Image" style="width: 20%; height: 20%;">
    </div>
</div>


## Installation

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/tulilirockz/universal-studio:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/tulilirockz/universal-studio:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/legacy-template
```
