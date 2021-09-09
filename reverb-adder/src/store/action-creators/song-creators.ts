import { SongActionType as ActionType } from "../action-types/song-action-types";
import { AppThunkAction } from "../actions/app-thunk-action";
import { Action, CreateSongAction } from "../actions/song-actions";

const actionCreators = {
    create: (reverb: boolean): AppThunkAction<Action> => async (dispatch, getState) => {
        
    }
    
};

export default actionCreators;