import { connectRouter } from 'connected-react-router';
import { applyMiddleware, combineReducers, compose, createStore, StoreEnhancer } from 'redux';
import thunk from 'redux-thunk';
import reducers from './reducers';
import { ApplicationState } from './states';
import { History } from 'history';

export default function configureStore(history: History, initialState?: ApplicationState) {
    const middleware = [
        thunk,
    ];

    const rootReducer = combineReducers({
        ...reducers,
        router: connectRouter(history)
    });

    const enhancers: StoreEnhancer[] = [];

    return createStore(
        rootReducer,
        initialState,
        compose(applyMiddleware(...middleware), ...enhancers)
    );
}