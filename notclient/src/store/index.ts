  
import { applyMiddleware, combineReducers, compose, createStore, StoreEnhancer } from 'redux';
import reducers from './reducers';
import { ApplicationState } from './states';
import thunk from 'redux-thunk';

export default function configureStore(initialState?: ApplicationState) {
    const middleware: any = [
        thunk
    ];

    const rootReducer = combineReducers({
        ...reducers,
    });

    const enhancers: StoreEnhancer[] = [];

    return createStore(
        rootReducer,
        initialState,
        compose(applyMiddleware(...middleware), ...enhancers)
    );
}