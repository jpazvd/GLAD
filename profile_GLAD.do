*==============================================================================*
* GLOBAL LEARNING ASSESSMENT DATABASE (GLAD)
* Project information at: https://github.com/worldbank/GLAD
*
* This initialization do sets paths, globals and install programs for GLAD Repo
*==============================================================================*
qui {


  *-----------------------------------------------------------------------------
  * General program setup
  *-----------------------------------------------------------------------------
  clear               all
  capture log         close _all
  set more            off
  set varabbrev       off, permanently
  set maxvar          10000
  version             15
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Define network path
  *-----------------------------------------------------------------------------
  * Network drive is always the same for everyone, but may not be available
  global network 	"//wbgfscifs01/GEDEDU/"
  cap cd "${network}"
  if _rc == 170   global network_is_available 1
  else            global network_is_available 0
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Define user-dependant global paths
  *-----------------------------------------------------------------------------
  * User-dependant paths for local repo clone
  * Aroob
  if inlist("`c(username)'","wb504672","WB504672") {
    global clone   "C:/Users/`c(username)'/OneDrive - WBG/Education/LearningTarget/Do/GLAD"
  }
  * Diana
  else if inlist("`c(username)'","wb552057","WB552057","diana") {
    global clone   "C:/Users/`c(username)'/Documents/Github/GLAD"
  }
  * Joao Pedro I
  else if inlist("`c(username)'","wb255520","WB255520") {
    global clone   "C:/Users/`c(username)'/Documents/mytasks/GLAD"
  }
  * Joao Pedro II
  else if inlist("`c(username)'","azeve") {
    global clone   "C:/GitHub/mytasks/GLAD"
  }
  * Joao Pedro III
  else if inlist("`c(username)'","jpazevedo") {
    global clone   "C:/GitHub/mytasks/GLAD"
  }
  * Natasha
  else if inlist("`c(username)'","wb419051","WB419051") {
    global clone   "C:/Users/wb419051/Documents/GitHub/GLAD"
  }
  /* WELCOME!!! ARE YOU NEW TO THIS CODE?
     Add yourself by copying the lines above, making sure to adapt your clone */
  else {
    noi disp as error _newline "{phang}Your username [`c(username)'] could not be matched with any profile. Please update profile_GLAD do-file accordingly and try again.{p_end}"
    error 2222
  }

  * Checks that files in the clone can be accessed by testing any clone file (like this one)
  cap confirm file "${clone}/profile_GLAD.do"
  if _rc != 0 {
    noi disp as error _newline "{phang}Having issues accessing your local clone of the GLAD repo. Please double check the clone location specified in profile_GLAD do-file and try again.{p_end}"
    error 2222
  }
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
  local user_commands fs pv seq mdesc alphawgt touch polychoric

  * Loop over all the commands to test if they are already installed, if not, then install
  foreach command of local user_commands {
    cap which `command'
    if _rc == 111 {
      * Polychoric is not in SSC so is checked separately
      if "`command'" == "polychoric" net install polychoric, from("http://staskolenikov.net/stata")
      *All other commands installed through SSC
      else  ssc install `command'
    }
  }

  * Load project specific ado-files
  cap net uninstall glad_toolkit
  net install glad_toolkit.pkg, from("${clone}/05_adofiles") replace

  * Check for EduAnalyticsToolkit package
  cap edukit
  if _rc != 0 {
    noi disp as err _newline "{phang}You don't have the required EduAnalytics Toolkit package installed. Please see this link for info on how to install it: https://github.com/worldbank/EduAnalyticsToolkit{p_end}"
    error 2222
  }
  else if `r(version)' < 1.0 {
    noi disp as err _newline "{phang}You have an outdated version of the required EduAnalytics Toolkit package installed. Please see this link for info on how to update it: https://github.com/worldbank/EduAnalyticsToolkit{p_end}"
    error 2222
  }

  /* NOTE: EDUKIT is the shortname of the the public repo EduAnalyticsToolkit.
     For info on the repo: https://github.com/worldbank/EduAnalyticsToolkit
     Always keep your edukit updated, for this run.do will do a version check.
     Unless you have the minimum version of the edukit package installed, it will not run */
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Make time-saving offers to user, requesting confirmation
  *-----------------------------------------------------------------------------
  * Check for batch mode or command-line options to skip interactive prompts
  * Usage: do profile_GLAD.do [/s | /h | /p | /b]
  *   /s = silent (skip prompts)
  *   /h = headless (skip prompts)  
  *   /p = programmatic (skip prompts)
  *   /b = batch (skip prompts)
  * Also auto-skips if running in actual batch mode
  
  local skip_prompt = 0
  
  * Check if any skip flag was passed as argument
  if inlist("`0'", "/s", "/h", "/p", "/b", "-s", "-h", "-p", "-b") {
    local skip_prompt = 1
  }
  
  * Check if running in batch mode
  if "`c(mode)'" == "batch" {
    local skip_prompt = 1
  }
  
  * Check if shortcut_GLAD is already defined (allows pre-setting)
  if `"${shortcut_GLAD}"' != "" {
    local skip_prompt = 1
  }
  
  if `skip_prompt' == 0 {
    * Offer to use a datalibweb shortcut (without manually typing it in the do files)
    noi di as txt _newline "{pstd}If you have a shortcut to query datalibweb enabled in your machine, please type your shortcut passcode and hit enter. In case you do not, simply hit enter without typing anything. Typing an invalid shortcut may cause the datalibweb queries to break.{p_end}", _request(shortcut_GLAD)
  }
  else {
    * In batch/silent mode, use empty shortcut if not pre-defined
    if `"${shortcut_GLAD}"' == "" {
      global shortcut_GLAD ""
    }
    noi di as txt _newline "{pstd}Running in batch/silent mode - skipping datalibweb shortcut prompt.{p_end}"
  }
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Flag that profile was successfully loaded
  *-----------------------------------------------------------------------------
  global GLAD_profile_is_loaded = 1
  noi disp as res _newline "{phang}GLAD profile sucessfully loaded.{p_end}"
  *-----------------------------------------------------------------------------

}
