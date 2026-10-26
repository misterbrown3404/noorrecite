# Reciter portraits

181 portraits are bundled for the 243-reciter MP3Quran directory. This adds 154
portraits to the original 27. The remaining 62 reciters use neutral avatars;
no sufficiently confident portrait match was found in the sources searched.
Their IDs and names are recorded in `assets/images/reciter_missing.json`.

Portraits were matched to reciter IDs through named English/Arabic profiles:
30 from Wikimedia Commons, 143 from Assabile, and 8 from RecitID. Ambiguous
similar-name matches were excluded.

The Assabile and RecitID pages do not specify image reuse licenses. These 151
images are explicitly marked as not verified for redistribution in the source
manifest and credits. Attribution does not grant permission. Commons images
retain the individual license information recorded with each image.

- Asset/source/license/author records: `assets/images/reciter_sources.json`
- Offline attribution: `assets/images/reciter_credits.txt`
- In-app attribution: Settings → Photo credits & licenses → Reciter portraits
- Shared lookup: `AppAssets.reciterImage(id)`
- Regenerate map/credits: `python3 scripts/build_reciter_assets.py`
- Validate decoding and attribution: `flutter test test/reciter_assets_test.dart`

The lookup is shared by the reciter directory, home reciter cards, audio picker,
and lock-screen artwork. Photos are bundled, so portraits need no network at
runtime. Avatar crops are presentation-only; local files are source thumbnails.
