import Layout from './components/Layout';
import { Route } from 'react-router';
import Reverb from './views/Reverb';
import Dereverb from './views/Dereverb';
import './App.css';

function App() {
  return (
    <Layout>
        <Route exact path='/' component={Reverb} />
        <Route exact path='/dereverb' component={Dereverb} />
    </Layout>
  );
}

export default App;
