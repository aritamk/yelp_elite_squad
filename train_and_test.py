import pandas
import numpy

from keras.models import Sequential
from keras.layers import Dense

from keras.wrappers.scikit_learn import KerasClassifier
from sklearn.preprocessing import StandardScaler

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
	seed = 7
	numpy.random.seed(seed)

	# load data to train on
	data_frame = pandas.read_csv('train.csv', header=None, encoding="utf-8")
	dataset = data_frame.values

	# get data cols and classification
	# data vector
	data_params = dataset[:, 0:num_categories].astype(float)
	# data class label
	data_class = dataset[:, total_cols] # or use dataset.shape[1]

	# build classifier and pass Model creation function
	print("Running Standardized Model")

	# standardize data
	estimators = []
	estimators.append(('standardize', StandardScaler()))
	estimators.append(('mlp', KerasClassifier(build_fn=create_baseline, epochs=100, batch_size=100, verbose=0)))

	# train model
	model = create_baseline()
	model.fit(data_params, data_class, epochs=75, batch_size=100, verbose=0)

	# evaluate accuracy
	scores = model.evaluate(data_params, data_class, verbose=0)
	print("%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))

	# test personal profile characteristics
	print("Key:\n0 = Not Elite, 1 = Elite")

	print("My Profile:")
	# Parameter Labels:
	#[5,2,0,0,3,0,128,2,4,2,0,1,0,3.85,0,58,1,2,0,3]
	#[5,2,0,0,3,0,128,2,4,2,0,1,0,3.85,0,0,58,1,2,0] # removed compliment profile and compliment cool
	# * replace with your own profile information *
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