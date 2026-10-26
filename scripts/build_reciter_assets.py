"""Generate the portrait map and offline credits from reviewed source metadata.

Run after manually verifying new assets and adding them to reciter_sources.json.
No name guessing or network access is performed by this generator.
"""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
rows = json.loads((root / 'assets/images/reciter_sources.json').read_text())
rows.sort(key=lambda row: row['id'])
assert len({row['id'] for row in rows}) == len(rows), 'Duplicate reciter IDs'
for row in rows:
    assert (root / row['asset']).is_file(), row['asset']
    assert row['source'] and row['license'] and row['author']

path = root / 'lib/core/constants/app_assets.dart'
text = path.read_text()
start = text.index('  /// Reciter portraits,') if '  /// Reciter portraits,' in text else text.index('  /// Verified reciter portraits')
end = text.index('  /// Returns the asset path', start)
block = '  /// Verified reciter portraits matched to named source profiles.\n'
block += '  /// Sources and licenses: assets/images/reciter_sources.json.\n'
block += '  /// Unmapped reciters deliberately use the neutral UI avatar.\n'
block += '  static const Map<int, String> reciterImages = {\n'
for row in rows:
    block += f"    {row['id']}: '{row['asset']}', // {row['name']}\n"
block += '  };\n\n'
path.write_text(text[:start] + block + text[end:])
credits = ['Reciter portrait credits', 'Source and rights information is recorded per image. Some directory sources do not state a reuse license; attribution is not permission. Thumbnails are displayed cropped to fit avatars.\n']
for row in rows:
    credits += [row['name'], 'Author: ' + row['author'], 'License: ' + row['license'], row['license_url'], 'Source: ' + row['source'], 'Biography: ' + row['profile'], 'Credit: ' + row['credit'], 'Changes: ' + row['changes'], row['permission'], '\n']
(root / 'assets/images/reciter_credits.txt').write_text('\n'.join(credits))
print(f'Generated {len(rows)} verified portrait mappings and credits.')
