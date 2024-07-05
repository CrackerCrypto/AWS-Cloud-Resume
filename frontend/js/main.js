window.addEventListener("DOMContentLoaded", (event) => {
  updateCounter();
});

const counter = document.querySelector("#counter");
const updateCounter = async () => {
  let response = await fetch(
    "https://lsr5o42aqlbfhj6lxcfmryb6pu0qkcdm.lambda-url.ap-south-1.on.aws/"
  );
  let data = await response.json();
  counter.innerText = `${data}`;
};
