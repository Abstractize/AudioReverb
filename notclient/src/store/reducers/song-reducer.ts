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
            console.log("Creating ...");
            return {
                isLoading: true,
                path: ''
            };
        case ActionType.SUCCESS:
            console.assert("SUCCESS");
            return {
                isLoading: false,
                path: action.path
            };
        case ActionType.FAILURE:
            console.error("ERROR!!!");
            return {
                isLoading: false,
                error: action.error,
                path: ''
            };
        default:
            return state;
    }
}

export default reducer;