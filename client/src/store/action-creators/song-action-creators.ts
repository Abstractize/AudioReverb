import { SongActionType as ActionType } from "../action-types/song-action-types";
import { AppThunkAction } from "../actions";
import { Action, CreateSongAction, FailureSongAction, SuccessSongAction } from "../actions/song-actions";
import { AudioService } from '../../infrastructure/services/audio-service';

const actionCreators = {
    create: (reverb: boolean): AppThunkAction<Action> => async (dispatch, getState) => {
        const appState = getState();
        const service = new AudioService();

        if (appState && appState.song) {
            service.post(null, reverb).then(value => value.data).then(data =>{
                console.log(data);
                dispatch({ type: ActionType.SUCCESS, path: data } as SuccessSongAction);
            }).catch(error => {
                console.error(error);
                dispatch({ type: ActionType.FAILURE, error: error } as FailureSongAction);
            });
        }
        dispatch({ type: ActionType.CREATE } as CreateSongAction);
    }

};

export default actionCreators;