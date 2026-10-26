"""Build reviewed ID mappings from the user-bundled OpenDua catalogue.
Arabic remains byte-for-byte unchanged in azkar.json. No network access.
"""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
base = root / 'assets/azkar'
source = json.loads((base / 'catalogue.json').read_text())
local = json.loads((base / 'azkar.json').read_text())
entries = {e['sourceReference']: e for e in source['entries']}
chapters = {c['id']: c for c in source['chapters']}
phonetics = (root / 'scripts/data/azkar_category_transliterations.txt').read_text().splitlines()
assert len(phonetics) == len(local)
audio_dir = 'assets/audio/azkar_audio/opendua-audio-hisn-v0.0.2/'
manifest = json.loads((root / audio_dir / 'manifest.json').read_text())
for track in manifest['tracks']:
    path = root / audio_dir / Path(track['key']).name
    assert path.stat().st_size == track['bytes'], path
    assert hashlib.sha256(path.read_bytes()).hexdigest() == track['sha256'], path

def clean(text):
    return text.replace('{{need}}', '[mention your need]').strip()

def render_steps(steps, label, translation, transliteration, recordings):
    for step in steps:
        if step['type'] == 'repeat':
            translation.append(f"Repeat the following sequence {step['times']} times:")
            render_steps(step['steps'], label, translation, transliteration, recordings)
        elif step['type'] == 'recitation':
            for item in step.get('items', []):
                dua = item['dua']
                suffix = f" (Repeat {item['times']} times.)" if item.get('times', 1) > 1 else ''
                translation.append(clean(dua['translation']) + suffix)
                transliteration.append(clean(dua['transliteration']) + suffix)
            for recording in step.get('recordings', []):
                asset = audio_dir + recording['url'].rsplit('/', 1)[-1]
                assert (root / asset).is_file(), asset
                recordings.append({'asset': asset, 'label': label or 'Recitation', 'duration_seconds': recording['durationSeconds']})
        elif step.get('text'):
            translation.append(clean(step['text']))

result = []
for category in local:
    translated_entries = []
    for item in category['array']:
        # This one original entry uses its chapter filename instead of reference 153.
        ref = '153' if category['id'] == 53 else item['filename']
        entry = entries[ref]
        translation, transliteration, recordings = [], [], []
        render_steps(entry.get('steps', []), '', translation, transliteration, recordings)
        for variant in entry.get('variations', []):
            label = variant.get('label', '')
            if label:
                translation.append(label + ':')
                transliteration.append(label + ':')
            render_steps(variant['steps'], label, translation, transliteration, recordings)
        # Original Arabic includes this concluding paragraph beyond OpenDua's steps.
        if ref == '74':
            translation.append('One who seeks the Creator’s guidance, consults believing people, and considers the matter carefully will not regret doing so. Allah says: “Consult them in the matter; then, when you have decided, place your trust in Allah.”')
        if ref == '92':
            translation.append('The supplied Arabic also allows saying it once when feeling too weary.')
        assert translation, ref
        for n, recording in enumerate(recordings):
            if len(recordings) > 1:
                recording['label'] += f' · Part {n + 1}'
        translated_entries.append({
            'id': item['id'], 'arabic': item['text'], 'source_reference': ref,
            'translation': '\n\n'.join(translation),
            'transliteration': '\n\n'.join(transliteration) or None,
            'audio': recordings,
        })
    title = chapters[entry['chapterId']]['title']
    if category['id'] == 1: title = 'Morning remembrance'
    if category['id'] == 2: title = 'Evening remembrance'
    result.append({'id': category['id'], 'title': title, 'transliteration': phonetics[category['id']-1], 'entries': translated_entries})
output = {
    'source': 'https://opendua.org/v0.0.4/catalogue.json',
    'data_version': source['dataVersion'],
    'attribution': 'OpenDua dataset v0.0.4, by Ihsan Labs at the Human Development Fund. Based on Hisn al-Muslim by Sa’id ibn Ali ibn Wahf al-Qahtani. OpenDua editorial text and dataset structure: CC BY 4.0. Recitation by Muhammad Jumah for OpenDua; audio has a separate licence.',
    'changes': 'Mapped to original categories; flattened nested steps with variant and repeat labels; category pronunciation guides authored for this app; original-Arabic notes added for entries 74 and 92. Instruction-only entries have English guidance rather than a recitation transliteration.',
    'categories': result,
}
(base / 'azkar_en.json').write_text(json.dumps(output, ensure_ascii=False, indent=2)+'\n')
print(f"Built {len(result)} categories / {sum(len(c['entries']) for c in result)} entries; verified {len(manifest['tracks'])} audio checksums.")
