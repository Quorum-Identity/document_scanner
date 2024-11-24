export interface ScannerConfig {
    openAIConfig: {
        apiKey: string;
    };
    scannerOptions?: {
        quality?: number;
        autoCapture?: boolean;
        documentType?: 'ID' | 'PASSPORT' | 'DRIVER_LICENSE';
    };
}
export interface ScanResult {
    image: string;
    extractedText: string;
    rawImage?: string;
    documentType?: string;
}
export interface DocumentScannerProps {
    config: ScannerConfig;
    onScanComplete: (result: ScanResult) => void;
    onError: (error: Error) => void;
    style?: any;
}
