% 2016-04-10 Leon Lai <Leon.Lai@pitt.edu>
%
% This function stimulates a layered feed-forward neural network with an input
% vector and captures the output values of each layer.
%
% Parameters:
%   lffnn:
%     layered feed-forward neural network like that returned by lffnn.
%   X:
%     matrix whose columns are input value vectors to stimulate lffnn with.
%
% Returns:
%   activity:
%     cell array whose (L)th cell contains a matrix whose (j)th row's (i)th
%     column is the output value of lffnn's (L)th layer's (j)th neuron when
%     stimulating lffnn with the (i)th input value vector, where the first
%     layer is the input layer. Note that lffnn_state{1} and lffnn_state{end}
%     are thus respectively the network's input and output.
%
function activity = passforward (lffnn, X)
% Note: activity{L} -> lffnn{L} -> activity{L+1}
L = 0 ;
activity{L+1} = X ;
%%
% Calculate activity for each intermediate layer.
for L = 1 : length(lffnn.weights) - 1 % is empty if length < 1
  % zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
  z=lffnn.biases{L}*ones(1,size(activity{L},2))+lffnn.weights{L}*activity{L};
  if lffnn.hidden_layers_are_sigpn
    % y = sigpn(z)
    activity{L+1} = (1 - exp(-z)) ./ (1 + exp(-z)) ;
  else
    % y = sig01(z)
    activity{L+1} =  1            ./ (1 + exp(-z)) ;
  end
end
%%
% Calculate activity for output layer.
L = length(lffnn.weights);
% zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
z = lffnn.biases{L}*ones(1,size(activity{L},2))+lffnn.weights{L}*activity{L};
% y = sig01(z)
activity{L+1} = 1 ./ (1 + exp(-z)) ;
