% 2015-04-29 Leon Lai <Leon.Lai@pitt.edu>
%
% This function generates a layered feed-forward neural network with a given
% number of layers, a given number of neurons for each layer, and random
% weights and bias within a given peak amplitude for each neuron not of the
% input layer.
%
% Parameters:
%   layer_spec:
%     array whose length is the number of layers that the network shall have
%     and whose (k)th element is the number of neurons that the (k)th layer of
%     lffnn shall have, where the first layer is the input layer.
%   rand_amp:
%     peak-to-peak amplitude of the randomly generated weights and biases.
%   hidden_layers_are_sigpn:
%     true if the twice-as-wide hyperbolic tangent function should be used for
%     hidden layer neurons, false if the sigmoid function should be used.
%
% Returns:
%   lffnn:
%     structure array whose fields 'weights' and 'biases' contain cell arrays;
%     the (L)th cell of 'weights' contains a matrix whose (j)th row's (k)th
%     column is the weight for the connection into the (L+1)th layer's (j)th
%     neuron from the (L)th layer's (k)th neuron; the (L)th cell of 'biases'
%     contains a column vector whose (j)th row is the bias of the (L+1)th
%     layer's (j)th neuron; the first layer is the input layer, whose neurons
%     have zero as biases and a single one as weights.
%
function lffnn = lffnn (layer_spec, rand_amp, hidden_layers_are_sigpn)
for L = 1 : length(layer_spec) - 1
  lffnn.weights{L} = rand_amp * (rand(layer_spec(L+1), layer_spec(L)) - 0.5);
  lffnn.biases {L} = rand_amp * (rand(layer_spec(L+1), 1            ) - 0.5);
end
lffnn.hidden_layers_are_sigpn = hidden_layers_are_sigpn;
