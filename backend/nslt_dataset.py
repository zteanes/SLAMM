import json
import os
import os.path

import cv2
import numpy as np
import torch
import torch.utils.data as data_utl


def video_to_tensor(pic):
    """Convert a ``numpy.ndarray`` to tensor.
    Converts a numpy.ndarray (T x H x W x C)
    to a torch.FloatTensor of shape (C x T x H x W)
    
    Args:
         pic (numpy.ndarray): Video to be converted to tensor.
    Returns:
         Tensor: Converted video.
    """
    return torch.from_numpy(pic.transpose([3, 0, 1, 2]))


def load_rgb_frames_from_video(vid_root, vid, start, num):
    print(vid_root)
    print(vid)
    video_path = os.path.join(vid_root, vid['video_id'] + '.mp4')

    vidcap = cv2.VideoCapture(video_path)
    # vidcap = cv2.VideoCapture('/home/dxli/Desktop/dm_256.mp4')

    frames = []

    vidcap.set(cv2.CAP_PROP_POS_FRAMES, start)
    for offset in range(num):
        success, img = vidcap.read()

        w, h, c = img.shape
        if w < 226 or h < 226:
            d = 226. - min(w, h)
            sc = 1 + d / min(w, h)
            img = cv2.resize(img, dsize=(0, 0), fx=sc, fy=sc)
        img = (img / 255.) * 2 - 1

        frames.append(img)

    return np.asarray(frames, dtype=np.float32)


def load_rgb_frames(image_dir, vid, start, end):
    frames = []
    for i in range(start, end):
        try:
            img = cv2.imread(os.path.join(image_dir, vid, "image_" + str(i).zfill(5) + '.jpg'))[:, :, [2, 1, 0]]
        except:
            print(os.path.join(image_dir, vid, str(i).zfill(6) + '.jpg'))
        w, h, c = img.shape
        if w < 226 or h < 226:
            d = 226. - min(w, h)
            sc = 1 + d / min(w, h)
            img = cv2.resize(img, dsize=(0, 0), fx=sc, fy=sc)
        img = (img / 255.) * 2 - 1
        frames.append(img)
    return np.asarray(frames, dtype=np.float32)


def load_flow_frames(image_dir, vid, start, num):
    frames = []
    for i in range(start, start + num):
        imgx = cv2.imread(os.path.join(image_dir, vid, vid + '-' + str(i).zfill(6) + 'x.jpg'), cv2.IMREAD_GRAYSCALE)
        imgy = cv2.imread(os.path.join(image_dir, vid, vid + '-' + str(i).zfill(6) + 'y.jpg'), cv2.IMREAD_GRAYSCALE)

        w, h = imgx.shape
        if w < 224 or h < 224:
            d = 224. - min(w, h)
            sc = 1 + d / min(w, h)
            imgx = cv2.resize(imgx, dsize=(0, 0), fx=sc, fy=sc)
            imgy = cv2.resize(imgy, dsize=(0, 0), fx=sc, fy=sc)

        imgx = (imgx / 255.) * 2 - 1
        imgy = (imgy / 255.) * 2 - 1
        img = np.asarray([imgx, imgy]).transpose([1, 2, 0])
        frames.append(img)
    return np.asarray(frames, dtype=np.float32)


def make_dataset(split_file, split, root, mode, num_classes):
    dataset = []
    with open(split_file, 'r') as f:
        data = json.load(f)

    i = 0
    for vid in data.keys():
        vid = data[vid]
        for instance in vid['instances']:
            if instance['split'] != split:
                continue # skip to the next instance of loop since it's not our split

            # get the id in instance for the video path
            path_to_video = os.getcwd() + "/data/start_kit/raw_videos_mp4" 
            video_path = os.path.join(path_to_video, instance['video_id'] + '.mp4')
            if not os.path.exists(video_path):
                continue
            # num_frames = data[vid]['action'][2] - data[vid]['action'][1]
            num_frames = int(cv2.VideoCapture(video_path).get(cv2.CAP_PROP_FRAME_COUNT))
            if mode == 'flow':
                num_frames = num_frames // 2

            label = np.zeros((num_classes, num_frames), np.float32)

            # dataset.append((vid, data[vid]['action'][0], data[vid]['action'][1], data[vid]['action'][2], "{}".format(vid)))
            dataset.append((vid, instance['instance_id'], 0, num_frames, "{}".format(vid)))
            # dataset.append((vid, label, 0, data[vid]['action'][2] - data[vid]['action'][1], "{}".format(vid)))
            i += 1
    print(len(dataset))
    return dataset


def get_num_class(split_file):
    classes = set()

    content = json.load(open(split_file))

    # # since we have sub dictionaries, we have to break down json file for use of .keys()
    # new_content = {}
    # # iterate every dictionary present in our json
    # for dic in content:
    #     # create entry with the key of gloss mapped to an empty dictionary
    #     new_content[dic['gloss']] = {}
    #     for y in dic.keys():
    #         if y == 'gloss': continue
    #         new_content[dic['gloss']][y] = dic[y]

    # # dump edited json back into a new json
    # with open('new_WLASL_v0.3.json', 'w') as f:
    #     json.dump(new_content, f, indent=4)

    # content = new_content

    for vid in content.keys():
        # class_id = content[vid]['action'][0]
        # classes.add(class_id)
        classes.add(vid)

    return len(classes)


class NSLT(data_utl.Dataset):

    def __init__(self, split_file, split, root, mode, transforms=None):
        self.num_classes = get_num_class(split_file)

        self.data = make_dataset(split_file, split, root, mode, self.num_classes)
        self.split_file = split_file
        self.transforms = transforms
        self.mode = mode
        self.root = root

    def __getitem__(self, index):
        """
        Args:
            index (int): Index

        Returns:
            tuple: (image, target) where target is class_index of the target class.
        """
        vid, label, start_f, start_e, output_name = self.data[index]

        if self.mode == 'rgb':
            # imgs = load_rgb_frames(self.root, vid, start_f, start_e)
            # imgs = load_rgb_frames(self.root, vid, start_f, start_e)
            imgs = load_rgb_frames_from_video(self.root, vid, start_f, start_e)
        else:
            imgs = load_flow_frames(self.root, vid, start_f, start_e)
        # label = label[:, start_f:start_e]

        imgs = self.transforms(imgs)
        ret_img = video_to_tensor(imgs)
        return ret_img, label, vid

    def __len__(self):
        return len(self.data)