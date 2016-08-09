% 2016-04-10 Leon Lai <Leon.Lai@pitt.edu>
%
% This function propagates back errors along an activated layered feed-forward
% neural network assuming online learning (stochastically choosing one case
% per epoch) and half-of-sum-of-square cost function.
%
% Parameters:
%   lffnn:
%     layered feed-forward neural network like that returned by lffnn.
%   activity:
%     network activity like that returned by passforward.
%   Y:
%     matrix whose columns are desired output value vectors.
%   dx:
%     learning rate, denoted by ε in Rumelhart et al. (1986).
%
% Returns:
%   lffnn:
%     same as parameter lffnn but with weights and biases updated by
%     backpropagation.
%
function lffnn = passbackward (lffnn, activity, Y, dx)
% Note: activity{L} -> lffnn{L} -> activity{L+1}
%%
% Calculate deltas for output layer.
L = length(lffnn.weights) ;
% ∂E/∂yⱼ where E = ½∑ⱼ(yⱼ-dⱼ)² assuming online learning
dE_dy = activity{L+1} - Y ;
% ∂E/∂zⱼ  = ∂E/∂yⱼ · ∂yⱼ/∂zⱼ  where yⱼ = sig01(zⱼ)
dE_dz = dE_dy .* (activity{L+1}) .* (1 - activity{L+1}) ;
% ∂E/∂wⱼᵢ = ∂E/∂zⱼ · ∂zⱼ/∂wⱼᵢ where zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
dE_dw = dE_dz * activity{L}' ;
% ∂E/∂bⱼ  = ∂E/∂zⱼ · ∂zⱼ/∂bⱼ  where zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
dE_db = dE_dz * 1 ;
% Δwⱼᵢ = -ε∂E/∂wⱼᵢ
delta_weights{L} = -dx * dE_dw ;
% Δbⱼ  = -ε∂E/∂bⱼ
delta_biases {L} = -dx * dE_db ;
%%
% Calculate deltas for each intermediate layer.
for L = L-1 : -1 : 1
  % ∂E/∂yᵢ = ∑ⱼ ∂E/∂zⱼ·∂zⱼ/∂yᵢ = ∑ⱼ ∂E/∂zⱼ·wⱼᵢ
  dE_dy = (dE_dz' * lffnn.weights{L+1})' ;
  % ∂E/∂zⱼ  = ∂E/∂yⱼ · ∂yⱼ/∂zⱼ
  if lffnn.hidden_layers_are_sigpn
    % yⱼ = sigpn(zⱼ)
    dE_dz = dE_dy .* (1 + activity{L+1}) .* (1 - activity{L+1}) .* 0.5 ;
  else
    % yⱼ = sig01(zⱼ)
    dE_dz = dE_dy .*      activity{L+1}  .* (1 - activity{L+1})        ;
  end
  % ∂E/∂wⱼᵢ = ∂E/∂zⱼ · ∂zⱼ/∂wⱼᵢ where zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
  dE_dw = dE_dz * activity{L}' ;
  % ∂E/∂bⱼ  = ∂E/∂zⱼ · ∂zⱼ/∂bⱼ  where zⱼ = bⱼ + ∑ᵢ wⱼᵢ·yᵢ
  dE_db = dE_dz * 1 ;
  % Δwⱼᵢ = -ε∂E/∂wⱼᵢ
  delta_weights{L} = -dx * dE_dw ;
  % Δbⱼ  = -ε∂E/∂bⱼ
  delta_biases {L} = -dx * dE_db ;
end
%%
% Adjust each layer's weights and biases.
for L = length(lffnn.weights) : -1 : 1
  lffnn.weights{L} = lffnn.weights{L} + delta_weights{L} ;
  lffnn.biases {L} = lffnn.biases {L} + delta_biases {L} ;
end
