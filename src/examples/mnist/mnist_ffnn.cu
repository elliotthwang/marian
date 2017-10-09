#include <algorithm>
#include <chrono>
#include <cstdio>
#include <iomanip>
#include <string>

#include <boost/timer/timer.hpp>

#include "marian.h"

#include "examples/mnist/model.h"
#include "examples/mnist/training.h"
#include "training/graph_group_async.h"
#include "training/graph_group_sync.h"
#include "training/graph_group_singleton.h"

const std::vector<std::string> TRAIN_SET
    = {"../src/examples/mnist/train-images-idx3-ubyte",
       "../src/examples/mnist/train-labels-idx1-ubyte"};
const std::vector<std::string> VALID_SET
    = {"../src/examples/mnist/t10k-images-idx3-ubyte",
       "../src/examples/mnist/t10k-labels-idx1-ubyte"};

using namespace marian;

int main(int argc, char** argv) {
  auto options = New<Config>(argc, argv, ConfigMode::training, false);

  if(!options->has("train-sets"))
    options->set("train-sets", TRAIN_SET);
  if(!options->has("valid-sets"))
    options->set("valid-sets", VALID_SET);

  if(options->get<std::string>("type") != "mnist-lenet")
    options->set("type", "mnist-ffnn");

  auto devices = options->get<std::vector<size_t>>("devices");

  if(devices.size() > 1) {
    if(options->get<bool>("sync"))
      New<TrainMNIST<SyncGraphGroup>>(options)->run();
    else
      New<TrainMNIST<AsyncGraphGroup>>(options)->run();
  } else
    New<TrainMNIST<SingletonGraph>>(options)->run();

  return 0;
}
