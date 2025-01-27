"""
This file was provided by WLASL (https://github.com/dxli94/WLASL) and finds missing 
videos in the json. Since it's a giant compilation of videos, many videos are removed 
or not available and this script identifies them and removes them from the json.
"""
import os
import json


filenames = set(os.listdir('videos'))

content = json.load(open('WLASL_v0.3.json'))

missing_ids = []

for entry in content:
    instances = entry['instances']

    for inst in instances:
        video_id = inst['video_id']
        if video_id + '.mp4' not in filenames:
            missing_ids.append(video_id)


with open('missing.txt', 'w') as f:
    f.write('\n'.join(missing_ids))

