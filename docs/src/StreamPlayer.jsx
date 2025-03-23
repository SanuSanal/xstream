import React from "react";
import { useLocation } from "react-router-dom";

const StreamPlayer = () => {
    const location = useLocation();
    const params = new URLSearchParams(location.search);

    const currentUrl = params.getAll('url')[0] || "https://www.vipbox.lc";

    return (
        <div className="stream-container">
            <iframe
                src={currentUrl}
                width="100%"
                height="100%"
                sandbox="allow-scripts allow-same-origin"
                allow="fullscreen"
            ></iframe>
        </div>
    );
};

export default StreamPlayer;
