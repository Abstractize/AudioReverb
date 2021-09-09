import { connect } from 'react-redux';
import Audio from '../../components/Audio';

const Reverb = () => (
    <div>
        <h1>Apply Reverb to the song!</h1>
        <Audio />
    </div>
);

export default connect()(Reverb);