Yelp Elite
==========

Languages: Python, with Keras/TensorFlow

Some background:
----------------

-   WHAT

    -   In case you’ve never heard of Yelp Elite Squad (YES), it’s a program
        that Yelp.com created that tries to provide people looking for good food
        with a way to get great reviews about local restaurants and businesses
        from regular people who’ve made it their duty to provide tips, feedback,
        pictures, and review information.

    -   Becoming part of the Yelp Elite Squad isn’t given lightly, and requires
        consistent checking-in, reviewing, and contribution through pictures and
        quality reviews. To learn more see
        https://www.yelp-support.com/article/What-is-Yelps-Elite-Squad?l=en_US

-   WHY

    -   This project initially started as an interest from the love of food and
        machine learning, and because I am a Elite Yelper, I wanted to see if
        there was actually any correlation between a person’s profile
        information (including myself) and whether they were elite or not. I
        decided to make it into a project where others could test out their
        profile themselves, and although it’s not just about numbers, see what
        areas they might want need to improve on in order to make it into the
        Yelp Elite Squad.

-   HOW

    -   This document describes the process to extract user profile data,
        convert it into ML-friendly data types, train on different sets of data,
        and test prepared data, as well as your own profile data to see if it’s
        Elite material

 

Provided Materials
==================

Windows
-------

-   \\windows contains the same script as in datasets\\yelp for converting the
    datasets from default data types in .csv to ML-friendly data types, with
    some parameters being removed (see below)

 

Datasets
--------

-   \datasets\yelp contains different versions of the original Yelp-provided
    dataset (json).

-   yelp_academic_dataset_user.csv is the original Yelp dataset that was
    converted into a .csv file using the script provided at \\utils.

    -   This script requires Python 2.7 to run

    -   To convert to csv run python json_to_csv_converter.py
        yelp_academic_dataset_user.csv

-   Reduce versions of this dataset (over 1.7GB) is provided in
    \\datasets\\yelp, with number of items 1k, 10k, 20k, and 50k

    -   These contain items such as Date Yelping Since, User ID, and Friends
        that are in formats that can't be processed and must be converted first.
        Use the Windows Powershell script at
        \\datasets\\yelp\\dataset_cleaner.ps1 to convert all of the necessary
        fields to numerical types that can be interpreted.

    -   There are already-converted versions of these .csv files located in
        datasets\yelp\prepared that can be copied to the same directory as the
        python scripts for quick training
		
-	After conversion, the users are split into segments of the first 80% for Training, and the remaining 20% for Testing
	-	This could additionally improve Training/Testing by randomizing the selection of users

 

**Note**: The last two parameters of the profile information have been removed
as they were unnecessary and were diluting the training and inference. Initially
each of these was being converted to a unique long value, but was causing issues
with classification. Date Yelping Since was converted to integer number of years
(from today’s year), yelping Friends IDs was converted to integer number of
friends, and User ID was removed

 

Scripts
-------

1.  load_and_test.py

    -   Loads the previously-trained model and tests against the test.csv
        dataset

    -   *Note:* Currently the name of the .csv file to be loaded and trained
        against is hard-coded to "train.csv". This can be updated to parse
        command line arguments

2.  train_save_test.py

    -   Loads train.csv dataset, trains model, saves model and weights, and
        tests model against test.csv dataset

    -   *Note: *Currently the name of the .csv file to be loaded and tested
        against is hard-coded to "train.csv". This can be updated to parse
        command line arguments

3.  train_and_test.py

    -   Loads train.csv dataset, trains model, and tests model against test.csv
        dataset

    -   Code for running tests against the test.csv can be uncommented to
        perform this part

    -   Code for single user profile classification can be uncommented to test
        on a specific profile

    -   *Note: *Currently the name of the .csv file to be loaded and trained
        against is hard-coded to "train.csv". This can be updated to parse
        command line arguments

 

Setup
-----

1.  Unzip user data

    1.  tar -xzvf yelp_dataset.tar yelp_academic_dataset_user.json

2.  Convert to csv for training

    1.  python json_to_csv_converter.py yelp_academic_dataset_user.json

3.  Convert data types

    1.  Move yelp_academic_dataset_user.json to same location as
        dataset_cleaner.ps1

    2.  Run ./dataset_cleaner.ps1 -f yelp_academic_dataset_user.json -ll 1

4.  Move \\datasets\\yelp\\datasets\\train.csv and test.csv to \\

 

At this point, you’ll have unzipped the default dataset, converted it to .csv,
and converted the data types within that csv.

You may also use the provided preprocessed datasets at
\\datasets\\yelp\\provided and rename each to “train.csv” and “test.csv” for
training and testing. Copy these to the location of the python scripts (”\\”)

 

### Suggested Virtual Environment

-   It’s suggested, and best practice, to create a virtual environment so that
    you may run the json converter (Python 2.7 required), and the training and
    inference scripts (Python 3.5 required) easily in separate environments

-   For the Python 3.5 training and inference environment,
    \\utils\\requirements.txt is provided and can be loaded into pip with “pip
    install -r requirements.txt”

-   Activate virtual environment for the remainder of the steps

 

Training & Testing
------------------

Assuming that all setup has been completed, the Python scripts should be located
in the same directory as the train.csv and test.csv data files

 

1.  Run python train_and_test.py

 

-   Expected output:

    -   The class is whether the user is elite or not based on their profile
        characteristics (parameters). 0 is Not Elite user 1 is Elite user

 

My profile data is provided here

[[ 2. 0. 0. 3. 0. 128. 2. 4. 2. 0. 1. 0. 3.85 0. 58. 1. 2. 0. 3. ]]

 

When running train_and_test.py on each of the datasets, you should expect to see
the following results:

Below, for each of the datasets that were trained against, my profile was
predicted to be Elite with different probability


Key: 0 = Not Elite, 1 = Elite

My Profile:
[[  2.     0.     0.     3.     0.   128.     2.     4.     2.     0.
    1.     0.     3.85   0.    58.     1.     2.     0.     3.  ]]

Predicted=[1], Actual: 1
Is Elite?: [ True]


1000 Users
acc: 98.12% Predicted prob=[0.8943053], Actual: 1


10000 Users
acc: 97.10% Predicted prob=[1.], Actual: 1


20000 Users
acc: 95.28% Predicted prob=[0.99998665], Actual: 1


50000 Users 
acc: 97.16% Predicted prob=[1.], Actual: 1
