import { Route } from 'react-router';
import Layout from './components/Layout';
import Reverb from './views/Reverb';

function App() {
  return (
    <Layout>
        <Route exact path='/' component={Reverb} />
    </Layout>
  );
}

export default App;
