export declare class OpenAIVisionService {
    private client;
    constructor(apiKey: string);
    extractText(base64Image: string): Promise<string>;
}
