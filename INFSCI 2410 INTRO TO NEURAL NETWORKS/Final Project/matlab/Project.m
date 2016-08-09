% -------------------------------------------------------------------------- %
%	CLASS   :  2154 INFSCI 2410 1250 INTRO TO NEURAL NETWORKS
%	AUTHOR  :  LAI, LEON <LIL65@PITT.EDU>
%	TITLE   :  Project
%	DATE    :  2016-04-10
% -------------------------------------------------------------------------- %

% A neural network simulation is to be written and executed several times to
% demonstrate it.  A written report is to be submitted including the code
% (MATLAB or any other language), a description of the code (this can be done
% in extensive comment statements), and a description of how the code performs
% (analysis).
%
% The paper should be between 5-10 pages, including the following sections:
% 1. BACKGROUND
%    - A description of the technique you are using including references.
% 2. METHOD DESCRIPTION
%    - The details of the model(s) you are using
%      - The number of units
%      - Learning rate
%      - etc.
%    - Include your program code.
% 3. PROBLEM DESCRIPTION
%    - The task(s) that are being computed or learned by the network.
% 4. RESULTS
%    - How well did the network perform?
% 5. CONCLUSION
%    - Did the network perform as expected?
%    - What did you learn from the simulation?
%
% For the final project, there are Options A, B, C, and D

%%
% Option A
% A constraint satisfaction network that solves a 4x4 Sudoku puzzle. The
% program should be given a 4x4 matrix M as input and return a 4x4 matrix
% S. The input matrix should have the numbers 1,2,3,4 in some locations and
% use 0 to indicate unfilled cells in the puzzle.
% For example:
%     0 0 4 0
% M = 1 0 0 0
%     0 0 0 3
%     0 1 0 0
% then
%     2 3 4 1
% S = 1 4 3 2
%     4 2 1 3
%     3 1 2 4
% The rules for Sudoku can be found at http://en.wikipedia.org/wiki/Sudoku.

%clear all ; close all ; clc ;



%%
% Option B: Autoassociative Network
% Create a network than will learn to auotassociate grayscale "images" on a
% 10x10 array. Thus the network will have 100 inputs and 100 outputs. Train
% the network on various sets that are restricted such as 3x3 squares,
% diamond-shaped inputs, etc. Your program should display the outputs of
% sample input images.

clear all ; close all ; clc ; diary ('B.log') ; rng (12345) ;

% Note: the variable "known" will contain all defined training and test sets,
% the variable "grown" will contain all testing results, and the variable
% "lffnns" will contain the trained neural networks and training metadata.

% Define training and test sets

known.train {1} = all_position_horizontal_line (10, 10, 3, 1, true) ;
known.train {2} = all_position_square          (10, 10, 3, 1, true) ;
known.train {3} = all_position_triangle        (10, 10, 3, 1, true) ;
for setindex = 1 : size (known.train, 2)
  for caseindex = 1 : size (known.train {setindex}, 2)
    im_col = known.train {setindex} (:, caseindex) ;
    im_col = imnoise (im_col, 'salt & pepper', 0.25) ;
    known.test_imnoise {setindex} (:, caseindex) = im_col ;
  end
end
known.test_zeros = zeros (100, 1) ;
known.test_ones  = ones  (100, 1) ;
known.test_rand  = rand  (100, 1) ;
fprintf ('known gathered.\n') ;

% Define neural network creation and training parameters

rand_amp = 1 ;                        % See lffnn.m
hidden_layers_are_sigpn = true ;      % See lffnn.m
max_training_iterations = 5e5 ;       % Upper limit of training iterations
m = 100 ;                             % Number of neurons in in/output layer
dx = 0.05 ;                           % Learning rate
for has_M = [1 2]                     % 1 if no (de)mapping layers
  for f = 1 : 20                      % Number of neurons in bottleneck layer
    for setindex=1:size(known.train,2)% Index of training set
      if has_M == 2
        M = f + 1 ;                   % Number of neurons in (de)mapping layer
        layer_spec = [m M f M m] ;
      else
        layer_spec = [m f m] ;
      end

      % Create neural network

      tic ;

      clear lffnn;
      lffnn = lffnn (layer_spec, rand_amp, hidden_layers_are_sigpn) ;

      % Train neural network: do online learning

      train = known.train {setindex} ;
      mistakes = zeros (1, size (train, 2)) - 1 ;
      % latest mistake counts per case
      training_iterations = 0 ;       % iters required to train to satisfation
      for caseindex = ceil(size(train,2)*rand(1,max_training_iterations))

        % This iteration's training set case

        X = train (:, caseindex) ;
        Y = X ;

        % Do feedforward

        activity = passforward (lffnn, X) ;

        % Determine if neural network has been sufficiently trained

        Yo = activity {end} ;
        E = abs (Yo - Y) ;
        mistakes (caseindex) = sum (E > 1/256) ;
        if mistakes == 0
          break;
        end

        % Do backpropagation

        lffnn = passbackward (lffnn, activity, Y, dx) ;
        training_iterations = training_iterations + 1 ;

      end

      training_seconds = toc ;

      % Gather training results

      lffnns {has_M, f, setindex} . lffnn = lffnn ;
      lffnns {has_M, f, setindex} . training_iterations = training_iterations;
      lffnns {has_M, f, setindex} . training_seconds = training_seconds ;

      fprintf ('lffnns{%d,%02d,%d} gathered (%f seconds).\n', ...
        has_M, f, setindex, training_seconds) ;

      % Test neural network using training and test sets

      for thing = fieldnames(known)'
        thing = char (thing) ;

        % Test

        if strcmp (thing, 'train') || strcmp (thing, 'test_imnoise')
          X = known.(thing) {setindex} ;
        else
          X = known.(thing) ;
        end
        Y = X ;
        activity = passforward (lffnn, X) ;
        Yo = activity {end} ;
        E = abs (Yo - Y) ;
        mistakes = E > 1/256 ;
        if strcmp (thing, 'train') || strcmp (thing, 'test_imnoise')
          Emean = mean (mean (E)) ;
        else
          Emean = mean (E) ;
        end
        if strcmp (thing, 'train') || strcmp (thing, 'test_imnoise')
          Emax = max (max (E)) ;
        else
          Emax = max (E) ;
        end
        if has_M
          data = activity {end - 2} ;
        else
          data = activity {end - 1} ;
        end

        % Gather test results

        grown . Yo       . (thing) {has_M, f, setindex} = Yo ;
        grown . E        . (thing) {has_M, f, setindex} = E ;
        grown . mistakes . (thing) {has_M, f, setindex} = mistakes ;
        grown . Emean    . (thing) {has_M, f, setindex} = Emean ;
        grown . Emax     . (thing) {has_M, f, setindex} = Emax ;
        grown . H        . (thing) {has_M, f, setindex} = data ;

      end

      fprintf ('grown.*.*{%d,%02d,%d} gathered.\n', has_M, f, setindex);

    end
  end
end

% Save gathered results

save ('B.mat', 'known', 'lffnns', 'grown') ;
fprintf ('%s, %s, %s saved.\n', 'known', 'lffnns', 'grown') ;

% Report training and test sets, training results, and evaluations with
% training and test sets

for thing = {'train' 'test_imnoise'}
  thing = char (thing) ;
  for setindex = 1 : size (known.(thing), 2)
    for caseindex = 1 : size (known.(thing) {setindex}, 2)
      im_col = known.(thing) {setindex} (:, caseindex) ;
      im = reshape (im_col, 10, 10) ;
      imwrite (im, sprintf ('B.%s.%d.%02d.png', thing, setindex, caseindex)) ;
    end
  end
end
for thing = {'test_zeros' 'test_ones' 'test_rand'}
  thing = char (thing) ;
  im_col = known.(thing) ;
  im = reshape (im_col, 10, 10) ;
  imwrite (im, sprintf ('B.%s.%02d.png', thing, caseindex)) ;
end
%{
% This block just produces too many files
for has_M = 1 : size (lffnns, 1)
  for f = 1 : size (lffnns, 2)
    for setindex = 1 : size (lffnns, 3)
      lffnn = lffnns {has_M, f, setindex} . lffnn ;
      for fieldname = {'weights' 'biases'}
        fieldname = char(fieldname);
        field = lffnn.(fieldname);
        for L = 1 : length (field)
          csvwrite (sprintf ('B.lffnn.%d.%02d.%d.%d_to_%d.%s.csv', ...
            has_M, f, setindex, L, L+1, fieldname), field{L});
        end
      end
    end
  end
end
%}
fprintf (',') ;
for has_M = 1 : size (lffnns, 1)
  for setindex = 1 : size(lffnns, 3)
    if has_M == 2
      fprintf (',set %d with M', setindex) ;
    else
      fprintf (',set %d', setindex) ;
    end
    fprintf (',') ;
    for thing = fieldnames(grown.Emean)'
      thing = char (thing) ;
      fprintf (',') ;
      fprintf (',') ;
    end
  end
end
fprintf ('\n') ;
fprintf ('f,1/256') ;
for has_M = 1 : size (lffnns, 1)
  for setindex = 1 : size(lffnns, 3)
    fprintf (',%s', 'seconds') ;
    fprintf (',%s', 'iterations') ;
    for thing = fieldnames(grown.Emean)'
      thing = char (thing) ;
      fprintf (',%s %s', thing, 'mean abs error') ;
      fprintf (',%s %s', thing, 'max abs error') ;
    end
  end
end
fprintf ('\n') ;
for f = 1 : size (lffnns, 2)
  fprintf ('%02d,%f', f, 1/256) ;
  for has_M = 1 : size (lffnns, 1)
    for setindex = 1 : size(lffnns, 3)
      fprintf (',%f', lffnns{has_M, f, setindex}.training_seconds);
      fprintf (',%6d', lffnns{has_M, f, setindex}.training_iterations);
      for thing = fieldnames(grown.Emean)'
        thing = char (thing) ;
        fprintf (',%f', grown.Emean.(thing){has_M, f, setindex}) ;
        fprintf (',%f', grown.Emax.(thing){has_M, f, setindex}) ;
      end
    end
  end
  fprintf ('\n') ;
end
%{
% This block possibly contains bugs and just produces too many files
for category = {'H' 'Yo' 'E' 'mistakes'}
  category = char (category) ;
  for has_M = 1 : size (lffnns, 1)
    for f = 1 : size (lffnns, 2)
      for setindex = 1 : size (lffnns, 3)
        for thing = {'train' 'test_imnoise'}
          thing = char (thing) ;
          data = grown.(category).(thing){has_M, f, setindex};
          for caseindex = 1 : size (data, 2)
            if strcmp (category, 'H')
              fprintf ([...
                'bottleneck layer activity ' ...
                '(thing=%s has_M=%d f=%02d setindex=%d caseindex=%02d): ' ...
                mat2str(data(:, caseindex)') ...
                '\n'], thing, has_M, f, setindex, caseindex);
            else
              im_col = data (:, caseindex) ;
              im = reshape (im_col, 10, 10) ;
              imwrite (im, sprintf (...
                'B.%s.%s.has_M=%d.f=%02d.setindex=%d.caseindex=%02d.png', ...
                category, thing, has_M, f, setindex, caseindex)) ;
            end
          end
        end
        for thing = {'test_zeros' 'test_ones' 'test_rand'}
          thing = char (thing) ;
          data = grown.(category).(thing){has_M, f, setindex};
          if strcmp (category, 'H')
            fprintf ([...
              'bottleneck layer activity ' ...
              '(thing=%s has_M=%d f=%02d setindex=%d): ' ...
              mat2str(data') ...
              '\n'], thing, has_M, f, setindex);
          else
            im_col = data ;
            im = reshape (im_col, 10, 10) ;
            imwrite (im, sprintf (...
              'B.%s.%s.has_M=%d.f=%02d.setindex=%d.png', ...
              category, thing, has_M, f, setindex)) ;
          end
        end
      end
    end
  end
end
%}

diary off ;



%%
% Option C: Classification Network
% Select a classification task. A training set and a test set should be
% generated. Either your task can be constructed by you or you can use real
% data such as the iris data set or any other data set, such as those on the
% Irvine Machine Learning Repository <http://archive.ics.uci.edu/ml/>. A
% description of the data set should be included in the written report.

%clear all ; close all ; clc ;



%%
% Option D: Travelling Salesman Problem
% Use the Hopfield technique (original paper available below) to solve the
% Travelling Salesman problem on two sets: small set of cities (5 or 6 cities)
% and apply it to the Berlin Data (52 y-y locations -- excel file included).

%clear all ; close all ; clc ;



%%
% References
% [1] Mark A. Kramer, "Autoassociative neural networks," Computers & Chemical Engineering, vol. 16, no. 4, pp. 313-328, Apr. 1992. <info:doi/10.1016/0098-1354(92)80051-A>
% [2] Mark A. Kramer, "Nonlinear principal component analysis using autoassociative neural networks," AIChE Journal, vol. 37, no. 2, pp. 233-243, Feb 1991. <info:doi/10.1002/aic.690370209>
% [3] David E. Rumelhart & Geoffrey E. Hinton & Ronald J. Williams, "Learning representations by back-propagating errors," Nature, vol. 323, no. 6088, pp. 475-566, Oct. 1986. <info:doi/10.1038/323533a0>
