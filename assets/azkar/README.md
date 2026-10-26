# Bundled worship content

The app reads these user-provided files offline:

- `azkar.json`: 133 categories / 291 entries. This is the primary category collection, with separate morning and evening sections.
- `dua.json`: 8 duas with Arabic, transliteration, translation, and reference.
- `asmaAlHusna.json`: 99 numbered names with Arabic, transliteration, and English meaning.

`adhkar.json` is retained but not loaded by the UI. Its 131 shared categories
have exactly the same entry arrays as `azkar.json`; its remaining category
combines morning and evening. Loading both would duplicate content.

Source wording, translations, references, and counts are preserved. This is a
structural integration, not an independent verification of religious content.
Some metadata counts differ from repetitions mentioned in the Arabic text (for
example, morning entry 9 has `count: 1` while its text mentions seven). The reader
labels metadata as “Listed repetitions” and permits free counting; it does not
silently rewrite these values or cap the counter.

## English and audio

`catalogue.json` is the user-bundled OpenDua v0.0.4 catalogue. The generated
`azkar_en.json` maps its translations, recitation pronunciation guides, nested
instructions, variants, and recording links onto all 133 original categories /
291 entries. Original Arabic and counts are unchanged. English is matched using
the Hisn reference in each original audio filename; category 53 uses the
explicit reference 153 override. Runtime loading also checks exact Arabic text,
so edited entries cannot silently inherit stale translations.

Regenerate with `python3 scripts/build_azkar_english.py`. This verifies SHA-256 and
byte lengths for all 249 bundled MP3s against the supplied audio manifest.
Category pronunciation guides are app-authored. English notes for the original
text’s additional guidance in references 74 and 92 are also app-authored.
Instruction-only entries receive an English explanation; pronunciation guides
cover the recitation portions, not narrative instructions. English and phonetic
layers are reading aids, not a claim of independent scholarly verification.

Text attribution: OpenDua dataset v0.0.4 (https://opendua.org), by Ihsan Labs at
the Human Development Fund. Based on Hisn al-Muslim by Sa’id ibn Ali ibn Wahf
al-Qahtani. OpenDua editorial text and dataset structure are licensed CC BY 4.0:
https://creativecommons.org/licenses/by/4.0/ . Adaptations: category mapping,
flattened ordered/repeated steps, readable placeholders, additional notes.

Audio: Muhammad Jumah for OpenDua, release v0.0.2. All 249 tracks are bundled
under `assets/audio/azkar_audio/opendua-audio-hisn-v0.0.2/`. The data’s CC BY licence
does not cover these recordings; audio terms: https://opendua.org/licence/audio .
The catalogue supplies exact recording-to-step mappings; entries without audio
have no playback button. Multipart and alternate recordings have separate labels.

Azkar borrows the existing background player, pauses Quran playback, and restores
the Quran queue and position (paused) when the reader closes. Preview events do
not update Quran progress or its duration cache.

Entry point: Home → Azkar → categories / Dua collection / 99 Names of Allah /
Tasbih counter. Category counters remain in memory for the open session.
