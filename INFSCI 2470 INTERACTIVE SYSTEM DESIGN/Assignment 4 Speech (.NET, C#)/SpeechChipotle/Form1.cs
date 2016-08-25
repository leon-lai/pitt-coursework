using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Speech.Recognition;
using System.Speech.Synthesis;
using System.Threading;

namespace SpeechChipotle
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        //SpeechRecognitionEngine instance.
        SpeechRecognitionEngine recognizer = new SpeechRecognitionEngine();
        SpeechSynthesizer synthesizer = new SpeechSynthesizer();

        // Steps
        const int FIRSTSTEP = 0;
        const int RICE = 1;
        const int BEANS = 2;
        const int MEAT = 3;
        const int FAJITAS = 4;
        const int SALSA = 5;
        const int CREAM = 6;
        const int LETTUCE = 7;
        const int LASTSTEP = 8;

        //bool both1, both2 = false;
        bool IsSalsaGr = true;//avoid unloading grammar twice
        bool IsCreamGr = true;
        bool IsLettuceGr = true;
        bool stopRec = false;
        Grammar gFirstStep = new Grammar("grammar.xml", "firstStep"); //new grammar instance
        Grammar gRice = new Grammar("grammar.xml", "rice");
        Grammar gBeans = new Grammar("grammar.xml", "beans");
        Grammar gMeat = new Grammar("grammar.xml", "meat");
        Grammar gFajitas = new Grammar("grammar.xml", "fajita");
        Grammar gSalsa = new Grammar("grammar.xml", "salsa");
        Grammar gCream = new Grammar("grammar.xml", "cream");
        Grammar gLettuce = new Grammar("grammar.xml", "lettuce");
        Grammar gLastStep = new Grammar("grammar.xml", "lastStep");

        string qFirstStep = "What can I get for you?";
        string qRice = "White or brown rice?";
        string qBeans = "Black or pinto beans?";
        string qMeat = "Chicken, steak, barbacoas, carnitas, or sofritas?";
        string qFajitas = "Any fahheetas?";
        string qSalsa = "Mild, medium, hot, or corn salsa?";
        string qCream = "Sour cream or cheese?";
        string qLettuce = "Lettuce or guacamole?";
        string qLastStep()
        {
            return "You ordered a " + aFirstStep + " with " + rice + " rice, " + beans + " beans, " + meat + ", " + salsa + Environment.NewLine + cream + cheese + lettuce + guacamole + fajitas + ", is that right?";
        }
       
        string aFirstStep;
        string meat = "", rice = "", beans = "", salsa = "", fajitas = "", cream = "", cheese = "", guacamole = "", lettuce = "";
        const double chickenPrice = 6.69;
        const double sofritasPrice = 6.69;
        const double carnitasPrice = 7.29;
        const double barbacoasPrice = 7.29;
        const double steakPrice = 7.29;
        const double guacamolePrice = 1.99;
        const double confidenceScore = 0.9;
        // everything else is zero so for now no other price definitions
        double price = 0; // initial;
        string aPrice()
        {
            return "Your total is $" + price.ToString("#.##");
        }
        string speak;

        void pauseRecognition(object sender, SpeakStartedEventArgs e)
        {
            recognizer.RecognizeAsyncStop();
            RecgModeLabel.ForeColor = Color.Red;
            RecgModeLabel.Text = "Recognition Paused ..";
        }

        void resumeRecognition(object sender, SpeakCompletedEventArgs e)
        {
            if (!stopRec)
            {
                recognizer.RecognizeAsync(RecognizeMode.Multiple);
                RecgModeLabel.ForeColor = Color.Green;
                RecgModeLabel.Text = "Recognizing ..";
            }

        }

        private void Form1_Load(object sender, EventArgs e)
        {
            recognizer.LoadGrammar(gFirstStep); //load the grammer to the engine
            recognizer.SetInputToDefaultAudioDevice();
            synthesizer.SelectVoiceByHints(VoiceGender.Neutral);
            synthesizer.SpeakStarted += new EventHandler<SpeakStartedEventArgs>(pauseRecognition);
            synthesizer.SpeakCompleted += new EventHandler<SpeakCompletedEventArgs>(resumeRecognition);
            synthesizer.SpeakAsync(qFirstStep);
            questionLabel.Text = qFirstStep;
            recognizer.RecognizeAsync(RecognizeMode.Multiple);
            recognizer.SpeechRecognized += recognizedFirstStep;
        }
        // Create a simple handler for the SpeechRecognized event.
        int step = FIRSTSTEP;
        void recognizedFirstStep(object sender, SpeechRecognizedEventArgs e)
        {
            if (e.Result.Confidence <= confidenceScore)
            {
                synthesizer.SpeakAsync("I'm sorry I can't hear you");
                textBox.ForeColor = Color.Red;
                textBox.Text = "confidence = " + e.Result.Confidence + Environment.NewLine + "response = " + e.Result.Text;
            }
            else
            {
                textBox.ForeColor = Color.Black;
                textBox.Text = "response = " + e.Result.Text + Environment.NewLine + "confidence = " + e.Result.Confidence;
            }
            if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("bowl"))//matches bowl and burrito bowl
            {
                aFirstStep = "bowl";
                recognizer.UnloadGrammar(gFirstStep);
                step = RICE;
                speak = qRice;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gRice);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("burrito"))//matches burrito
            {
                aFirstStep = "burrito";
                recognizer.UnloadGrammar(gFirstStep);
                step = RICE;
                speak = qRice;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gRice);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("white"))
            {
                rice = "white";
                recognizer.UnloadGrammar(gRice);
                step = BEANS;
                speak = qBeans;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gBeans);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("brown"))
            {
                rice = "brown";
                recognizer.UnloadGrammar(gRice);
                step = BEANS;
                speak = qBeans;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gBeans);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("black"))
            {
                beans = "black";
                recognizer.UnloadGrammar(gBeans);
                step = MEAT;
                speak = qMeat;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gMeat);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("pinto"))
            {
                beans = "pinto";
                recognizer.UnloadGrammar(gBeans);
                step = MEAT;
                speak = qMeat;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.LoadGrammar(gMeat);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("chicken"))
            {
                meat = "chicken";
                price += chickenPrice;
                step = FAJITAS;
                speak = qFajitas;
                questionLabel.Text = "Any fajitas?";
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gMeat);
                recognizer.LoadGrammar(gFajitas);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("steak"))
            {
                meat = "steak";
                price += steakPrice;
                step = FAJITAS;
                speak = qFajitas;
                questionLabel.Text = "Any fajitas?";
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gMeat);
                recognizer.LoadGrammar(gFajitas);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("barbacoas"))
            {
                meat = "barbacoas";
                price += barbacoasPrice;
                step = FAJITAS;
                speak = qFajitas;
                questionLabel.Text = "Any fajitas?";
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gMeat);
                recognizer.LoadGrammar(gFajitas);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("carnitas"))
            {
                meat = "carnitas";
                price += carnitasPrice;
                step = FAJITAS;
                speak = qFajitas;
                questionLabel.Text = "Any fajitas?";
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gMeat);
                recognizer.LoadGrammar(gFajitas);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("sofritas"))
            {
                meat = "sofritas";
                price += sofritasPrice;
                step = FAJITAS;
                speak = qFajitas;
                questionLabel.Text = "Any fajitas?";
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gMeat);
                recognizer.LoadGrammar(gFajitas);
            }
            else if ((e.Result.Confidence > confidenceScore && (e.Result.Text.Contains("yes") || e.Result.Text.Contains("yeah"))) && (step == 4))
            {
                step = SALSA;
                fajitas = "fahheetas";
                speak = qSalsa;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak);
                recognizer.UnloadGrammar(gFajitas);
                recognizer.LoadGrammar(gSalsa);
            }
            else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("no") && step == 4)
            {
                step = SALSA;
                fajitas = "";
                speak = qSalsa;
                questionLabel.Text = speak;
                synthesizer.SpeakAsync(speak); 
                recognizer.UnloadGrammar(gFajitas);
                recognizer.LoadGrammar(gSalsa);
            }
            else //multiple items allowed
            {
                if (e.Result.Text == "none" && step == 5 && e.Result.Confidence > confidenceScore)
                {
                    step = CREAM;
                    speak = qCream;
                    questionLabel.Text = speak;
                    synthesizer.SpeakAsync(speak); 
                    recognizer.UnloadGrammar(gSalsa);
                    recognizer.LoadGrammar(gCream);
                    IsSalsaGr = false;
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("mild"))
                {
                    step = CREAM;
                    if (!salsa.Contains("mild"))
                        salsa += "mild salsa, ";
                    if (IsSalsaGr)
                    {
                        speak = qCream;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gSalsa);
                        recognizer.LoadGrammar(gCream);
                        IsSalsaGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("medium"))
                {
                    step = CREAM;
                    if (!salsa.Contains("medium"))
                        salsa += "medium salsa, ";
                    if (IsSalsaGr)
                    {
                        speak = qCream;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gSalsa);
                        recognizer.LoadGrammar(gCream);
                        IsSalsaGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("hot"))
                {
                    step = CREAM;
                    if (!salsa.Contains("hot salsa,"))
                        salsa += "hot salsa, ";
                    if (IsSalsaGr)
                    {
                        speak = qCream;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gSalsa);
                        recognizer.LoadGrammar(gCream);
                        IsSalsaGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("corn"))
                {
                    step = CREAM;
                    if (!salsa.Contains("corn"))
                        salsa += "corn, ";
                    if (IsSalsaGr)
                    {
                        speak = qCream;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gSalsa);
                        recognizer.LoadGrammar(gCream);
                        IsSalsaGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && ((e.Result.Text == "no" || e.Result.Text == "no thanks" || e.Result.Text.Contains("neither")) && step == 6))
                {
                    step = LETTUCE;
                    if (IsCreamGr)
                    {
                        speak = qLettuce;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gCream);
                        recognizer.LoadGrammar(gLettuce);
                        IsCreamGr = false;
                    }
                }
                else if (e.Result.Confidence > confidenceScore && (e.Result.Text.Contains("no") || e.Result.Text.Contains("neither")) && step == 7)
                {
                    step = LASTSTEP;
                    speak = qLastStep();
                    questionLabel.Text = speak;
                    synthesizer.SpeakAsync(speak); 
                    recognizer.UnloadGrammar(gLettuce);
                    recognizer.LoadGrammar(gLastStep);
                    IsLettuceGr = false;
                }
                if (e.Result.Text == "both" && step == 6 && e.Result.Confidence > confidenceScore)
                {
                    step = LETTUCE;
                    cream = "sour cream, ";
                    cheese = "cheese, ";
                    if (IsCreamGr)
                    {
                        speak = qLettuce;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gCream);
                        recognizer.LoadGrammar(gLettuce);
                        IsCreamGr = false;
                    }
                }
                else if (e.Result.Text == "both" && step == 7 && e.Result.Confidence > confidenceScore)
                {
                    step = LASTSTEP;
                    guacamole = "guacamole, ";
                    price += guacamolePrice;
                    lettuce = "lettuce, ";
                    if (IsLettuceGr)
                    {
                        speak = qLastStep();
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gLettuce);
                        recognizer.LoadGrammar(gLastStep);
                        IsLettuceGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("sour cream"))
                {
                    step = LETTUCE;
                    cream = "sour cream, ";
                    if (IsCreamGr)
                    {
                        speak = qLettuce;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gCream);
                        recognizer.LoadGrammar(gLettuce);
                        IsCreamGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("cheese"))
                {
                    step = LETTUCE;
                    cheese = "cheese, ";
                    if (IsCreamGr)
                    {
                        speak = qLettuce;
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gCream);
                        recognizer.LoadGrammar(gLettuce);
                        IsCreamGr = false;
                    }
                }
                if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("guacamole") && e.Result.Text.Contains("lettuce"))
                {
                    step = LASTSTEP;
                    guacamole = "guacamole, ";
                    price += guacamolePrice;
                    lettuce = "lettuce, ";
                    if (IsLettuceGr)
                    {
                        speak = qLastStep();
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gLettuce);
                        recognizer.LoadGrammar(gLastStep);
                        IsLettuceGr = false;
                    }
                }
                else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("guacamole"))
                {
                    step = LASTSTEP;
                    guacamole = "guacamole, ";
                    price += guacamolePrice;
                    if (IsLettuceGr)
                    {
                        speak = qLastStep();
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gLettuce);
                        recognizer.LoadGrammar(gLastStep);
                        IsLettuceGr = false;
                    }
                }
                else if (e.Result.Confidence > confidenceScore && e.Result.Text.Contains("lettuce"))
                {
                    step = LASTSTEP;
                    lettuce = "lettuce, ";
                    if (IsLettuceGr)
                    {
                        speak = qLastStep();
                        questionLabel.Text = speak;
                        synthesizer.SpeakAsync(speak); 
                        recognizer.UnloadGrammar(gLettuce);
                        recognizer.LoadGrammar(gLastStep);
                        IsLettuceGr = false;
                    }
                }
                if (e.Result.Text == "yes" && e.Result.Confidence > confidenceScore)
                {
                    stopRec = true;
                    speak = aPrice();
                    questionLabel.Text = speak;
                    synthesizer.SpeakAsync(speak); 
                    recognizer.RecognizeAsyncStop();
                }
                else if (e.Result.Text == "no" && e.Result.Confidence > confidenceScore)
                {
                    IsCreamGr = true;
                    IsSalsaGr = true;
                    IsLettuceGr = true;
                    meat = ""; rice = ""; beans = ""; salsa = ""; fajitas = ""; cream = ""; cheese = ""; guacamole = ""; lettuce = "";
                    price = 0;
                    step = FIRSTSTEP;
                    speak = "Sorry about that. Let's start over. Do you want a bowl or burrito?";
                    questionLabel.Text = speak;
                    synthesizer.SpeakAsync(speak); 
                    recognizer.UnloadGrammar(gLastStep);
                    recognizer.LoadGrammar(gFirstStep);
                }
            }
        }//recognizedFirstStep

        private void textBox_TextChanged(object sender, EventArgs e)
        {

        }
    }
}