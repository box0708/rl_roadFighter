
%% The same as defeintions in 'exercise1.m'.
% Generate the variables needed.
UP_LEFT = 1 ;
UP = 2 ;
UP_RIGHT = 3 ;

% PROBLEM SPECIFICATION:

blockSize = 5 ; 
n_MiniMapBlocksPerMap = 5 ; 
basisEpsisodeLength = blockSize - 1 ;

episodeLength = blockSize*n_MiniMapBlocksPerMap - 1 ;
%discountFactor_gamma = 1 ; % if needed
rewards = [ 1, -1, -20 ] ; 

probabilityOfUniformlyRandomDirectionTaken = 0.15 ;

roadBasisGridMaps = generateMiniMaps ; 

tempGrid = [ roadBasisGridMaps(2).Grid; ...
  roadBasisGridMaps(3).Grid; roadBasisGridMaps(2).Grid; ...
  roadBasisGridMaps(8).Grid; roadBasisGridMaps(7).Grid ] ;

tempStart = [ n_MiniMapBlocksPerMap * blockSize, 1 ] ;

tempMarkerRescaleFactor = 1/( (25^2)/36 ) ;

MDP_1 = GridMap(tempGrid, tempStart, tempMarkerRescaleFactor, ...
    probabilityOfUniformlyRandomDirectionTaken) ;

% Appending a matrix (same size size as the grid) with the locations of 
% cars:
MDP_1.CarLocations = [0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     1     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     1     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     1     0     0     0 ; ...
                      0     0     1     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     1     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     0     0     0 ; ...
                      0     0     1     0     0 ; ...
                      0     0     0     0     0 ];

MDP_1.RewardFunction = generateRewardFunction( MDP_1, rewards ) ;

%% Deterministic Policy to evaluate:
pi_test1 = UP * ones( MDP_1.GridSize ); % Default action: up.
pi_test1(:, 1) = UP_RIGHT; % When on the leftmost column, go up right.
pi_test1(:, 5) = UP_LEFT ; % When on the rightmost column, go up left.
pi_test1(:, 3) = UP_LEFT ; % When on the center column, go up left.

pi_test1_stateNumbers = zeros(1,125);
pi_test1_stateNumbers(:) = pi_test1';

%%

value_function = zeros(MDP_1.GridSize(1), MDP_1.GridSize(2) );
value_function = policy_evaluation(MDP_1, value_function, pi_test1);
pi_old = pi_test1;
pi_new = policy_improvement(pi_test1, value_function);

while any(any(pi_old ~= pi_new))
    value_function = policy_evaluation(MDP_1, value_function, pi_new);
    pi_old = pi_new;
    pi_new = policy_improvement(pi_new, value_function);
    disp('###')
end
%disp(value_function)
disp(pi_new)


%%

%%
currentTimeStep = 0 ;
currentMap = MDP_1 ;
agentLocation = currentMap.Start ;
startingLocation = agentLocation ; % Keeping record of initial location.

% If you need to keep track of agent movement history:
%
agentMovementHistory = zeros(episodeLength+1, 2) ;
%
agentMovementHistory(currentTimeStep + 1, :) = agentLocation ;


%% PRINT MAP:
% You can update viewableGridMap in a similar way as below, in order to
% keep track of the current visible area for your car (don't use this with
% road bases since the whole map should be visible at any time in that case
% ): 
viewableGridMap = ...
    setCurrentViewableGridMap( MDP_1, agentLocation, blockSize ) ;
% When printing $viewableGridMap.Grid$ notice that the row numbers no
% longer correspond to the original test map rows. Use $agentLocation(1)$  
% to keep track of your current row in the complete test map.

refreshScreen % See $refreshScreen$ function for details.


%% TEST ACTION TAKING, MOVING WINDOW AND TRAJECTORY PRINTING:
% Simulating agent behaviour when following the policy defined by 
% $pi_test1$.
%
% Commented lines also have examples of use for $GridMap$'s $getReward$ and
% $getTransitions$ functions, which act as our reward and transition
% functions respectively.

realAgentLocation = agentLocation ; % The location on the full test map.
Return = 0;

for i = 1:episodeLength
    
    
    %actionTaken = pi_test1( realAgentLocation(1), realAgentLocation(2) );
    actionTaken = pi_new( realAgentLocation(1), realAgentLocation(2) );
    
    % The $GridMap$ functions $getTransitions$ and $getReward$ act as the 
    % problems transition and reward function respectively.
    %
    % $actionMoveAgent$ can be used to simulate agent (the car) behaviour.
    
     [ possibleTransitions, probabilityForEachTransition ] = ...
         MDP_1.getTransitions( realAgentLocation, actionTaken );
     [ numberOfPossibleNextStates, ~ ] = size(possibleTransitions);
     previousAgentLocation = realAgentLocation;
    
    [ agentRewardSignal, realAgentLocation, currentTimeStep, ...
        agentMovementHistory ] = ...
        actionMoveAgent( actionTaken, realAgentLocation, MDP_1, ...
        currentTimeStep, agentMovementHistory, ...
        probabilityOfUniformlyRandomDirectionTaken ) ;

     MDP_1.getReward( ...
             previousAgentLocation, realAgentLocation, actionTaken )
    
    Return = Return + agentRewardSignal;
    
    % If you want to view the agents behaviour sequentially, and with a 
    % moving view window, try using $pause(n)$ to pause the screen for $n$
    % seconds between each draw:
       
    [ viewableGridMap, agentLocation ] = setCurrentViewableGridMap( ...
        MDP_1, realAgentLocation, blockSize );
    % $agentLocation$ is the location on the viewable grid map for the 
    % simulation. It is used by $refreshScreen$.
    
    currentMap = viewableGridMap ; %#ok<NASGU>
    % $currentMap$ is keeping track of which part of the full test map
    % should be printed by $refreshScreen$ or $printAgentTrajectory$.
    
    refreshScreen
   
    fprintf('The episode is %.0f\n', i)
    disp(realAgentLocation);
    %disp(agentLocation);
    fprintf('The action is %.0f\n', actionTaken)
    fprintf('The reward is %8.5f\n', agentRewardSignal)
    fprintf('The return is %8.5f\n', Return)
    
    pause(0.1)
    
end

currentMap = MDP_1 ;
agentLocation = realAgentLocation ;

Return

printAgentTrajectory

