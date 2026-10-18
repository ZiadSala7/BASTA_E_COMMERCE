# Image Asset Guidelines

Recommended image dimensions for the home banner carousel and product images in the Flutter app.

## Quick reference

| Image use | Display ratio (width:height) | Recommended export | Minimum practical export |
| --- | ---: | ---: | ---: |
| Home carousel banner | 1.9:1 | 1900 × 1000 px | 1200 × 630 px |
| Product card image | 1.18:1 | 1200 × 1020 px | 800 × 680 px |
| Product detail/gallery image | Any ratio; square is preferred | 1200 × 1200 px | 800 × 800 px |

Ratios are width divided by height. Export dimensions are source pixels, not Flutter logical pixels.

## Home carousel banners

- Design for **1.9:1**. The carousel calculates card height from its page width using this ratio on typical phone layouts.
- Use **1900 × 1000 px** as the default export. Keep important visual content near the center because the remote image uses `BoxFit.cover` and may be cropped on unusually narrow or wide layouts.
- Leave the lower portion visually quiet: the app overlays a dark gradient, title, and call-to-action near the bottom.
- Avoid baking text, buttons, or logos into the image. Use the banner title and button fields so text remains readable and can adapt to the app's layout and language.
- Use JPEG for photographic artwork or WebP when the image pipeline supports it. Keep a high-quality source; optimize the delivered file to limit download time.

## Product images

- For product cards, target **1.18:1** and export at **1200 × 1020 px**. This closely matches the image area in the product card, reducing unwanted stretching.
- Use a plain or transparent background where appropriate, center the product, and leave a small margin so the product is not clipped by rounded card corners.
- Product detail and full-screen gallery views use `BoxFit.contain`, so the full image remains visible. A **square 1200 × 1200 px** image is a versatile default for product galleries and works well for most catalog photography.
- Keep the product's framing and background consistent across images in the same catalog. Use additional gallery images for alternate angles and details rather than placing multiple views in one image.
- Prefer JPEG for standard product photography and PNG or WebP when transparency is needed. Resize and compress uploads for delivery; avoid serving unnecessarily large originals.

## Implementation reference

- The home carousel uses a 1.9:1 page-width-to-card-height calculation, with minimum and maximum card-height limits. Banner images from the network use `BoxFit.cover`.
- Product cards give the image an aspect ratio of 1.18:1 and currently render it with `BoxFit.fill`.
- Product detail and gallery images render with `BoxFit.contain`; their visible frame depends on the device layout.

If these display ratios change in the UI, update this guide and the recommended export ratios together.
