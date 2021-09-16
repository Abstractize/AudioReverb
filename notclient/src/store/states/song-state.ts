export class Song {
    constructor(
        public isLoading: boolean = true,
        public path: string = '',
        public error?: string,
    ) { }
}