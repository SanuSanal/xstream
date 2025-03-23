import { useEffect, useRef, useState } from 'react'
import logo from './assets/image.png'
import './App.css'
import { useLocation } from 'react-router-dom';
import APKDownloader from './components/FileDownloader';

function App() {
  const [isChecked, setIsChecked] = useState(false);
  const contactUs = useRef(null);
  const location = useLocation();

  useEffect(() => {
    const hash = location.hash;
    if (hash === '#contact-us' && contactUs.current) {
      contactUs.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [location]);

  const handleCheckboxChange = (event) => {
    setIsChecked(event.target.checked);
  };

  const handleDownloadClick = () => {
    window.open("https://github.com/SanuSanal/xstream/releases", "_blank");
  };

  return (
    <>
      <div className={`container-fluid d-flex flex-column flex-md-row ${window.innerWidth <= 768 ? '' : 'vh-100'}`}>
        <div className="col-md-6 d-flex justify-content-center align-items-center bg-white">
          <img
            src={logo}
            alt="XStream Icon"
            className="img-fluid"
          />
        </div>

        <div className="col-md-6 d-flex flex-column justify-content-center align-items-center text-center bg-white p-4">
          <h1 className="display-4 fw-bold mb-3 text-dark">Welcome to XStream</h1>
          <p className="fs-5 text-secondary mb-4">
            The ultimate app for seamless video streaming! Whether you're a football fanatic or a movie lover, XStream lets you stream live from various sites, completely hassle-free.
          </p>

          <APKDownloader />

          <h1 className="mt-5 display-6 fw-bold">How to Use XStream</h1>
          <ul className="list-unstyled mt-3">
            <li className="d-flex align-items-center mb-3">
              <img src="https://img.icons8.com/ios-filled/50/000000/menu.png" alt="Drawer Icon" className="me-3" width="24" />
              <span>Open the App Drawer from the top left corner.</span>
            </li>
            <li className="d-flex align-items-center mb-3">
              <img src="https://img.icons8.com/ios-filled/50/000000/settings.png" alt="Settings Icon" className="me-3" width="24" />
              <span>Navigate to Settings to configure your homepage.</span>
            </li>
            <li className="d-flex align-items-center mb-3">
              <img src="https://img.icons8.com/ios-filled/50/000000/plus-math.png" alt="Plus Icon" className="me-3" width="24" />
              <span>Add a stream site by tapping the plus button.</span>
            </li>
            <li className="d-flex align-items-center">
              <img src="https://img.icons8.com/material-sharp/24/checked--v1.png" alt="Checkmark Icon" className="me-3" width="24" />
              <span>Tap on the checkmark to set the stream site as homepage.</span>
            </li>
          </ul>
        </div>
      </div>

      <div className="container-fluid py-5">
        <div className="row justify-content-center">
          <div className="col-lg-6">
            <div ref={contactUs} className="contact-form p-4 border rounded shadow-sm bg-white">
              <h1 className="text-center mb-4">Contact Developer</h1>
              <form
                className="row"
                action="https://getform.io/f/anledowa"
                method="post"
              >
                <div className="col-md-6 mb-3">
                  <input
                    type="text"
                    className="form-control"
                    name="name"
                    id="name"
                    placeholder="Your Name"
                    required
                  />
                </div>
                <div className="col-md-6 mb-3">
                  <input
                    type="email"
                    className="form-control"
                    name="email"
                    id="email"
                    placeholder="Your Email"
                    required
                  />
                </div>
                <div className="col-md-12 mb-3">
                  <textarea
                    className="form-control"
                    id="message"
                    name='message'
                    placeholder="Message here…"
                    required
                    rows="4"
                  ></textarea>
                </div>
                <div className="col-md-12 mb-3">
                  <div className="form-check">
                    <input
                      className="form-check-input"
                      type="checkbox"
                      id="gridCheck"
                      onChange={handleCheckboxChange}
                      checked={isChecked}
                    />
                    <label className="form-check-label" htmlFor="gridCheck">
                      I agree that my submitted data is being collected and stored.
                    </label>
                  </div>
                </div>
                <div className="col-lg-12 text-center">
                  <button
                    type="submit"
                    className="btn btn-primary px-4 py-2"
                    disabled={!isChecked}
                  >
                    Send Message
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>

      <div className="d-flex flex-column">
        <footer className="footer text-center py-3 mt-auto bg-light">
          <p>© 2025 XStream. All rights reserved.</p>
          <p>Web App version 0.0.3</p>
        </footer>
      </div>
    </>
  )
}

export default App
