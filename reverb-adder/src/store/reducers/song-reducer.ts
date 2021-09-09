  
import { Reducer } from "react";
import { SongActionType as ActionType } from "../action-types/song-action-types";
import { Action } from "../actions/song-actions";
import { Song as State } from "../states/song-state";

const initialState = new State();

export const reducer: Reducer<State, Action> = (state: State | undefined, action: Action): State => {
    if (state === undefined)
        return initialState;
    
    switch (action.type) {
        case ActionType.CREATE:
            return {
                isLoading: true
            };
        case ActionType.SUCCESS:
            return {
                isLoading: false
            };
        case ActionType.FAILURE:
            return {
                isLoading: false,
                error: action.error
            };
        default:
            return state;
    }
}

export default reducer;