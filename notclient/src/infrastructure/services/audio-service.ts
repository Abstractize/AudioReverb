import axios, { AxiosResponse } from 'axios';

export class AudioService{
    protected url: string = 'http://localhost:5000/api/Audio';

    public async post(file: File, reverb: boolean): Promise<AxiosResponse<string>>{
        return axios.post(`${this.url}/${reverb}`, file);
    }
}