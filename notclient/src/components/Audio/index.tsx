import React from "react";
import ReactAudioPlayer from 'react-audio-player';
import { DotLoader } from 'react-spinners';

export default class Audio extends React.Component<{ title: string, src: string, dst: string, loading: boolean, load: () => void }> {
    componentDidMount() {
        this.props.load();
    }
    
    renderAudioWithEffect() {
        return (
            <ReactAudioPlayer
                src={this.props.dst}
                controls
            />
        )
    }

    render() {
        let content = this.props.loading ?
            <>
                <div style={{
                    position: 'absolute', left: '50%', top: '50%',
                    transform: 'translate(-50%, -50%)'
                }}>
                    <DotLoader size={100} loading={this.props.loading} />
                </div>
            </>
            : this.renderAudioWithEffect();
        return (
            <div>
                <h1>{this.props.title}</h1>
                <p>
                    Original Audio
                </p>
                <ReactAudioPlayer
                    src={this.props.src}
                    controls
                />
                <p>
                    Effect Audio
                </p>
                {content}
            </div>
        );
    }
}