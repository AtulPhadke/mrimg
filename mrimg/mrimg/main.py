import sys
from tkinter import *
from tkinter import filedialog
from brukerapi.dataset import Dataset
import nibabel as nib
import matplotlib.pyplot as plt
from pydicom import dcmread
from pydicom.dataset import Dataset as DS
import ntpath
import numpy as np
import subprocess
#from read_2dseq import load_2dseq


f_types = ["dicom", "nifti", "bruker 2dseq"]
c_types = ["convert", "analyze"]

def convert(file1_type, file2_type, file1_path, file2_path, split3D):
    if file1_type == "bruker 2dseq":
        dataset = Dataset(file1_path)
        if file2_type == "nifti":
            if len(dataset.data.shape) > 3:
                if split3D == 1.0:
                    applescript = """"""
                    extra_applestring = "\nchoose from list {"
                    for x in dataset.data.shape:
                        extra_applestring += ("\"" + str(x) + "\",")
                    extra_applestring = list(extra_applestring)
                    extra_applestring[-1] = "}"
                    extra_applestring = "".join(extra_applestring)
                    applescript += extra_applestring
                    applescript += "with title \"mrimg\" with prompt \"Pick which slice to split the image into.\""
                    img_slice = subprocess.check_output("osascript -e '{}'".format(applescript), shell=True)
                    print("img_slice:" + str(img_slice))
                    new_shape = list(dataset.data.shape[::-1])
                    index_slice = list(dataset.data.shape[::-1]).index(int(img_slice))
                    new_shape[0], new_shape[index_slice] = new_shape[index_slice], new_shape[0]
                    print(new_shape)
                    for idx, img in enumerate(np.reshape(np.transpose(np.rot90(dataset.data)), new_shape)):
                        #print(img.shape)

                        output_image = nib.Nifti1Image(img, None)
                        nib.save(output_image, file2_path+str(idx+1)+".nii")
                else:
                    output_image = nib.Nifti1Image(dataset.data, None)
                    nib.save(output_image, file2_path+".nii")
            else:
                output_image = nib.Nifti1Image(dataset.data, None)
                nib.save(output_image, file2_path+".nii")
        elif file2_type == "dicom":
            ds = DS()
            ds.pixel_array = dataset.data
            ds.save(file2_path+".dcm")
    elif file1_type == "nifti":
        output_image = nib.Nifti1Image(dataset.data, None)
        ds = DS()
        ds.pixel_array = output_image.data
        ds.save(file2_path)
    elif file1_type == "dicom":
        output_image = nib.Nifti1Image(dcmread(file1_path), None)
        nib.save(output_image, "new_img.nii")
