import React, { useEffect, useState } from "react";

const APKDownloader = () => {

    const [apkOptions, setApkOptions] = useState([
        { name: "arm64 v8a APK", file: "" },
        { name: "armeabi v7a APK", file: "" },
        { name: "x86 APK", file: "" },
    ]);

    const [selectedApk, setSelectedApk] = useState(apkOptions[0]);

    const [version, setVersion] = useState('Fetching...');

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await fetch('https://api.github.com/repos/SanuSanal/xstream/releases/latest');
                const data = await response.json();

                setVersion(`v${data['tag_name']}`);

                const v8a = data?.assets?.find(asset => asset.name.includes('arm64-v8a'))?.browser_download_url;
                const v7a = data?.assets?.find(asset => asset.name.includes('armeabi-v7a'))?.browser_download_url;
                const x86_64 = data?.assets?.find(asset => asset.name.includes('x86_64'))?.browser_download_url;

                apkOptions[0].file = v8a;
                apkOptions[1].file = v7a;
                apkOptions[2].file = x86_64;

                setApkOptions(apkOptions);

            } catch (error) {
                console.error('Error fetching data:', error);
            }
        };

        fetchData();
    }, []);

    const handleSelect = (apk) => {
        setSelectedApk(apk);
    };

    const handleDownload = () => {
        if (selectedApk.file.length === 0) {
            window.open("https://github.com/SanuSanal/xstream/releases", "_blank");
        } else {
            const link = document.createElement("a");
            link.href = selectedApk.file;
            link.download = selectedApk.name;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    };

    return (
        <>
            <span className="badge bg-info text-dark mb-2">Latest Version: {version}</span>

            <div className="btn-group">

                <div className="dropdown">
                    <button
                        className="btn btn-secondary btn-lg dropdown-toggle"
                        type="button"
                        id="apkDropdown"
                        data-bs-toggle="dropdown"
                        aria-haspopup="true"
                        aria-expanded="false"
                    >
                        {selectedApk.name}
                    </button>
                    <div className="dropdown-menu" aria-labelledby="apkDropdown">
                        {apkOptions.map((apk, index) => (
                            <button
                                key={index}
                                className="dropdown-item"
                                onClick={() => handleSelect(apk)}
                            >
                                {apk.name}
                            </button>
                        ))}
                    </div>
                </div>

                <button className="btn btn-primary btn-lg" type="button" onClick={handleDownload}>
                    Download
                </button>
            </div>
        </>
    );
};

export default APKDownloader;
