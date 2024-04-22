module.exports = (hostname) => {
  const protocol = 'http';
  const removeDefault = [
    'iframe',
  ];
  // Define your test scenarios here.
  const scenarios = [
    {
      'label': 'User login page',
      'url': `${protocol}://${hostname}/user`,
      'removeSelectors': removeDefault
    }
  ];

  // Define your breakpoints here.
  const viewports = [
    {
      'label': 'Breakpoint_XS',
      'width': 320,
      'height': 450
    },
    {
      'label': 'Breakpoint_S',
      'width': 576,
      'height': 630
    },
    {
      'label': 'Breakpoint_M',
      'width': 768,
      'height': 920
    },
    {
      'label': 'Breakpoint_L',
      'width': 992,
      'height': 650
    },
    {
      'label': 'Breakpoint_XL',
      'width': 1024,
      'height': 580
    },
    {
      'label': 'Breakpoint_XXL',
      'width': 2560,
      'height': 1440
    }
  ];

  return { scenarios, viewports };
};
