import pandas
import numpy

from keras.models import Sequential
from keras.layers import Dense

from keras.models import model_from_json
from keras.models import model_from_yaml

total_cols = 19
num_categories = total_cols


def create_baseline():
	model = Sequential()
	model.add(Dense(38, input_dim=num_categories, kernel_initializer='normal', activation='relu'))
	model.add(Dense(1, kernel_initializer='normal', activation='sigmoid'))
	model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
	print("Model:\n", model.summary())
	return model


def main():

	# Load JSON, YAML, and HDF5
	print("Loading JSON, YAML, and HDF5")
	# load json model
	json_file = open('model.json', 'r')
	loaded_model_json = json_file.read()
	json_file.close()
	loaded_json = model_from_json(loaded_model_json)
	loaded_model = loaded_json

	# load yaml file
	yaml_file = open('model.yaml', 'r')
	loaded_model_yaml = yaml_file.read()
	yaml_file.close()
	loaded_yaml = model_from_yaml(loaded_model_yaml)
	loaded_model = loaded_yaml
	print("model loaded")

	# load model weights
	loaded_model.load_weights("model_weights.h5")
	loaded_model.compile(loss='binary_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
	print("weights loaded")

	# load test dataset and measure trained model/weights against it
	# use test set to test against (assumes model has been trained on train.csv)
	test_dataframe = pandas.read_csv('test.csv', header=None, encoding="utf-8")
	test_dataset = test_dataframe.values

	# test against loaded data
	train_X = test_dataset[:, 0:num_categories].astype(float)
	train_Y = test_dataset[:, total_cols]
	score = loaded_model.evaluate(train_X, train_Y, verbose=0)
	print("%s: %.2f%%" % (loaded_model.metrics_names[1], score[1] * 100))

	# create new model and run baseline (uninitialized network)
	# this compares the baseline model to the loaded model (just shows difference)
	model = create_baseline()
	score = model.evaluate(train_X, train_Y, verbose=0)
	print("Baseline %s: %.2f%%" % (model.metrics_names[1], score[1] * 100))

	# set weights to new model and test again
	model_weights = loaded_model.get_weights()
	model.set_weights(model_weights)
	score = model.evaluate(train_X, train_Y, verbose=0)
	print("Updated %s: %.2f%%" % (model.metrics_names[1], score[1] * 100))

	# test weights on new model against same test data
	score = loaded_model.evaluate(train_X, train_Y, verbose=0)
	print("%s: %.2f%%" % (loaded_model.metrics_names[1], score[1] * 100))

	# test personal profile characteristics
	# here we test against our own profile data to determine whether Yelp Elite or not)
	print("Key:\n0 = Not Elite, 1 = Elite")

	print("My Profile:")
	# replace with your own profile information
	my_profile = numpy.array([[2,0,0,3,0,128,2,4,2,0,1,0,3.85,0,58,1,2,0,3]])
	print(my_profile)

	my_ynew = model.predict_proba(my_profile)
	print("Predicted prob=%s, Actual: %i" % (my_ynew[0], 1))

	my_ynew = model.predict_classes(my_profile)
	print("Predicted=%s, Actual: %i" % (my_ynew[0], 1))
	print("Is Elite?: %s" % (my_ynew[0] == 1))
	
	return 0
	

if __name__ == "__main__":
	main()
