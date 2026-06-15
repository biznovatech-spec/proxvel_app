import re

path = 'lib/integration/mock/mock_destination_data_source.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r"imageUrl:\s*'.*?'", "imageUrl: ''", content)
content = re.sub(r"galleryImages:\s*\[.*?\]", "galleryImages: []", content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Mock cleaned')
