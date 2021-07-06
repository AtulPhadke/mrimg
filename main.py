import sys
from tkinter import *
from tkinter import filedialog
from brukerapi.dataset import Dataset
import nibabel as nib
import matplotlib.pyplot as plt
from pydicom import dcmread
from pydicom.dataset import Dataset as DS
import ntpath

f_types = ["dicom", "nifti", "bruker 2dseq"]
c_types = ["convert", "analyze"]

def convert(file1_type, file2_type, file1_path, file2_path):
    if file1_type == "bruker 2dseq":
        dataset = Dataset(file1_path)
        if file2_type == "nifti":
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
