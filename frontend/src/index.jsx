import React from 'react';
import ReactDOM from 'react-dom';

const baseURL = process.env.ENDPOINT;

const getWeatherFromApi = async () => {
  try {
    const response = await fetch(`${baseURL}/weather`);
    return response.json();
  } catch (error) {
    console.error(error);
  }

  return {};
};

class Weather extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      icon: "",
      message: "hot bind test"
    };
  }

  async componentDidMount() {
    const weather = await getWeatherFromApi();
    this.setState({icon: weather.icon.slice(0, -1)});
  }

  render() {
    const { icon , message} = this.state;

    return (
      <div className="icon">
        { icon && <img src={`/img/${icon}.svg`} /> }
        <h1>{message}</h1>
      </div>
    );
  }
}

ReactDOM.render(
  <Weather />,
  document.getElementById('app')
);
