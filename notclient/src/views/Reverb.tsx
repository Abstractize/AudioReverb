import React from "react";
import { connect } from "react-redux";
import Audio from '../components/Audio';
import { ApplicationState } from "../store/states";
import ActionCreators from '../store/action-creators/song-action-creators';
import { Song } from "../store/states/song-state";

type Props = Song & typeof ActionCreators;

class Reverb extends React.PureComponent<Props>
{
    title: string = 'Reverb';
    src: string = 'asm/resong.wav';
    dest: string = this.props.path;

    render(){
        return(
            <Audio title={this.title} src= {this.src} dst= {this.dest} loading={this.props.isLoading} load={() => this.props.create(true)}/>
        );
    }
}

export default connect(
    (state: ApplicationState) => ({ ...state.song }),
    ({... ActionCreators})
)(Reverb as any);