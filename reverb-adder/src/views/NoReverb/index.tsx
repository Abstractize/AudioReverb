import * as React from 'react';
import { connect } from 'react-redux';
import Audio from '../../components/Audio';

const NoReverb = () => (
    <div>
        <h1>Deapply Reverb to the song!</h1>
        <Audio/>
    </div>
);

export default connect()(NoReverb);