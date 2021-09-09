  
import { Action as ReduxAction } from "redux";
import { SongActionType as ActionType } from "../action-types/song-action-types";

interface SongAction extends ReduxAction<ActionType> {
    type: ActionType
}

export interface CreateSongAction extends SongAction {
    type: ActionType.CREATE,
    reverb: boolean
}

export interface SuccessSongAction extends SongAction {
    type: ActionType.SUCCESS
}

export interface FailureSongAction extends SongAction {
    type: ActionType.FAILURE,
    error: string
}

export type Action = CreateSongAction | SuccessSongAction | FailureSongAction;