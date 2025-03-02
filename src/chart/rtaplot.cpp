/**
 *  OSM
 *  Copyright (C) 2018  Pavel Smokotnin

 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include "rtaplot.h"
#include "rtaseriesrenderer.h"

using namespace Fftchart;

RTAPlot::RTAPlot(Settings *settings, QQuickItem *parent): XYPlot(settings, parent),
    m_mode(0),
    m_pointsPerOctave(12),
    m_spline(false), m_coherence(false)
{
    x.configure(AxisType::logarithmic, 20.f, 20000.f);
    x.setISOLabels();
    y.configure(AxisType::linear, -90.f,    0.f,  9);
    setFlag(QQuickItem::ItemHasContents);
    connect(this, SIGNAL(modeChanged(unsigned int)), this, SLOT(update()));
    connect(this, SIGNAL(pointsPerOctaveChanged(unsigned int)), this, SLOT(update()));
}
SeriesFBO* RTAPlot::createSeriesFromSource(Source *source)
{
    return new SeriesFBO(source, [](){return new RTASeriesRenderer();}, this);
}
void RTAPlot::setMode(unsigned int mode)
{
    if (m_mode == mode)
        return;
    m_mode = mode;
    emit modeChanged(m_mode);
}
void RTAPlot::setPointsPerOctave(unsigned int p)
{
    if (m_pointsPerOctave == p)
        return;

    m_pointsPerOctave = p;
    emit pointsPerOctaveChanged(m_pointsPerOctave);
    update();
}
void RTAPlot::setCoherence(bool coherence) noexcept
{
    if (m_coherence == coherence)
        return;
    m_coherence = coherence;
    emit coherenceChanged(m_coherence);
    update();
}
void RTAPlot::setSettings(Settings *settings) noexcept
{
    if (settings && (settings->value("type") == "RTA")) {
        XYPlot::setSettings(settings);

        setMode(
            m_settings->reactValue<RTAPlot, unsigned int>("mode", this, &RTAPlot::modeChanged, m_mode).toUInt());
        setCoherence(
            m_settings->reactValue<RTAPlot, bool>("coherence", this, &RTAPlot::coherenceChanged, m_coherence).toBool());
        setPointsPerOctave(
            m_settings->reactValue<RTAPlot, unsigned int>("pointsPerOctave", this, &RTAPlot::pointsPerOctaveChanged, m_pointsPerOctave).toUInt());
    }
}
void RTAPlot::storeSettings() noexcept
{
    if (!m_settings)
        return;

    XYPlot::storeSettings();
    m_settings->setValue("mode", m_mode);
    m_settings->setValue("coherence", m_coherence);
    m_settings->setValue("pointsPerOctave", m_pointsPerOctave);
}
